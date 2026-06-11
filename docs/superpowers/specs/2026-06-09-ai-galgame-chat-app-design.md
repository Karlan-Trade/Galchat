# AI Galgame Chat App Design

Date: 2026-06-09

## Summary

Build an Android-first Flutter app for AI-powered Galgame-style chatting. The app looks and behaves like a normal mobile chat app, but AI replies can include Galgame choices and state changes. The first version does not include character sprites, background art, voice, accounts, cloud sync, or a custom backend server.

The app is intended for personal use and future open-source release. Users configure their own API endpoint and key. The app does not embed a developer-owned API key.

## Goals

- Provide a playable mobile MVP quickly.
- Support normal free-text chatting with an AI character.
- Let AI replies include 2-4 selectable Galgame choices.
- Persist conversations, messages, character state, and branch flags locally.
- Support JSON backup export/import without requiring a server.
- Keep the codebase structured for future custom character cards and additional providers.

## Non-goals for MVP

- No visual novel sprites or background scenes.
- No voice synthesis or speech recognition.
- No user accounts.
- No cloud sync.
- No developer-hosted API proxy.
- No iOS build support in the first implementation pass, though Flutter architecture should not intentionally block it.
- No multi-character UI in MVP.
- No full剧情 editor or node graph system.

## Platform and Tech Stack

- Framework: Flutter.
- Initial platform: Android only.
- State management: Riverpod.
- Local database: Drift over SQLite.
- Secure secrets: flutter_secure_storage for API keys.
- Networking: Dart HTTP client layer hidden behind an AI provider interface.
- Backup format: JSON export/import.

## Security Model

The app has no standalone backend server. AI requests are sent directly from the phone to the configured OpenAI-compatible endpoint.

Because client-side apps cannot safely hide secrets, the app must not ship with a developer-owned API key. The first-run/settings flow asks the user to enter their own API key. Store that key only in platform secure storage.

Backup files must not include the API key by default. They may include non-secret settings such as base URL and model name.

## Core User Flow

1. User opens the app.
2. If API settings are missing, user goes to Settings and enters Base URL, API Key, and Model.
3. User creates or opens a save/conversation.
4. User sends a free-text message or taps a choice.
5. App sends recent conversation context, current character card, and current game state to the AI provider.
6. AI ideally returns JSON containing character messages, choices, and state deltas.
7. App parses the JSON, renders chat bubbles and choices, then updates local game state.
8. If parsing fails, app stores and renders the raw AI response as a normal message and offers retry/repair actions.

## MVP Pages

### 1. Chat Page

Responsibilities:

- Render user and character chat bubbles.
- Render pending/loading states while waiting for AI.
- Render the current set of AI-provided choices below the latest AI response.
- Allow free-text input.
- Allow tapping a choice as the next user action.
- Support retry for failed API calls.
- Support regenerate or attempt-format-repair for malformed AI output.

Key UI expectations:

- Similar to a normal mobile messaging app.
- No full visual novel stage.
- Choices appear as buttons/chips near the input area or below the latest response.

### 2. Save / Conversation List Page

Responsibilities:

- List conversations/saves.
- Create a new conversation.
- Continue an existing conversation.
- Delete a conversation after confirmation.
- Export backup JSON.
- Import backup JSON.

### 3. Settings Page

Responsibilities:

- Edit Base URL.
- Edit API Key.
- Edit Model.
- Test connection.
- Configure simple generation parameters where compatible, including max tokens and temperature.

Notes:

- Some OpenAI-compatible endpoints may ignore or reject specific generation parameters. The provider layer should handle errors clearly.
- API Key should be masked in the UI and saved via secure storage.

## Character System

MVP includes one built-in character: 初雪.

Default character setup:

- World: modern campus daily life.
- Role: AI/android catgirl disguised as a transfer student.
- Secret: only the user knows she is an android.
- Personality: clingy and cute, with a light teasing/tsundere edge and ATRI-like emotional flavor.
- Tone: sweet, relaxed, daily-life romance.

Design the data model so future versions can support custom character cards. Suggested fields:

- id
- name
- display_name
- avatar_path or avatar_color, optional for MVP
- system_prompt
- greeting
- world_setting
- reply_style
- created_at
- updated_at

## Game State System

MVP state includes:

```json
{
  "affection": 0,
  "mood": "平静",
  "scene": "教室",
  "time_slot": "放学后",
  "flags": {
    "joined_club": false,
    "saw_android_secret": true
  }
}
```

State fields:

- affection: integer affection score.
- mood: current character mood.
- scene: current narrative location.
- time_slot: current time segment.
- flags: JSON object of branch tags and important decisions.

AI replies can include `state_delta` to update these fields. The app owns final state merging and validation.

## AI Provider Design

The MVP targets OpenAI-compatible chat completion APIs.

Settings:

- Base URL.
- API Key.
- Model.
- Optional generation parameters.

Expected request shape:

```http
POST {baseUrl}/chat/completions
Authorization: Bearer {apiKey}
Content-Type: application/json
```

The app should build provider-specific requests inside an abstraction, for example:

```dart
abstract class AiProvider {
  Future<AiTurnResult> sendTurn(AiTurnRequest request);
  Future<ConnectionTestResult> testConnection(AiSettings settings);
}
```

MVP implementation:

- `OpenAiCompatibleProvider`.

Future implementations may include:

- Claude/Anthropic native provider.
- Gemini provider.
- Local model provider.

## AI Response Contract

The app prompts the model to return JSON first. Ideal response:

```json
{
  "messages": [
    {
      "speaker": "初雪",
      "text": "主人，今天放学后要不要陪初雪去社团活动室喵？"
    }
  ],
  "choices": [
    {
      "id": "A",
      "text": "答应初雪，一起去社团活动室"
    },
    {
      "id": "B",
      "text": "故意逗她：你是不是很想和我独处？"
    }
  ],
  "state_delta": {
    "affection": 1,
    "mood": "期待",
    "flags": {
      "promised_after_school": true
    }
  }
}
```

Parsing behavior:

1. Try to parse the AI output as JSON.
2. Validate that `messages` is present and usable.
3. If valid, store messages, choices, and state updates.
4. If invalid, store the raw text as a character message and do not update game state.
5. Show repair/regenerate controls for malformed output.

The JSON-first fallback approach is required because OpenAI-compatible providers vary in their support for structured outputs.

## Local Data Model

Use Drift/SQLite tables similar to:

### characters

- id
- name
- display_name
- system_prompt
- greeting
- world_setting
- reply_style
- created_at
- updated_at

### conversations

- id
- character_id
- title
- created_at
- updated_at
- archived_at nullable

### messages

- id
- conversation_id
- role: user | assistant | system | error
- speaker nullable
- content
- raw_payload nullable
- created_at

### choices

- id
- conversation_id
- message_id
- choice_key
- text
- selected_at nullable

### game_states

- conversation_id
- affection
- mood
- scene
- time_slot
- flags_json
- updated_at

### ai_settings

Non-secret provider settings may live in the database or preferences:

- base_url
- model
- max_tokens
- temperature

API key must live in secure storage, not this table.

## Backup Design

Export JSON should include:

- schema_version
- characters
- conversations
- messages
- choices
- game_states
- non-secret AI settings, optionally

Export JSON should exclude by default:

- API Key.
- Any secure storage secrets.

Import should:

- Validate schema_version.
- Import into local database transactionally.
- Avoid overwriting existing conversations unless the user confirms or IDs are remapped.

## Prompting Strategy

Each AI request should include:

- Character card/persona.
- Output contract requiring JSON.
- Current game state.
- Recent conversation history.
- User input or selected choice.

Prompt should instruct the model to:

- Speak as 初雪 only unless otherwise required.
- Keep responses chat-app-friendly, not long prose blocks.
- Include 2-4 choices when appropriate.
- Return valid JSON with `messages`, `choices`, and `state_delta`.
- Keep state deltas small and meaningful.

Because providers vary, the app must tolerate non-JSON output.

## Error Handling

API/network errors:

- Show a failed message state.
- Offer retry.
- Preserve the user's unsent or failed input.

Authentication errors:

- Show a settings-focused error explaining that the key or endpoint may be invalid.

Malformed AI output:

- Render raw text as a normal response.
- Do not update game state.
- Offer repair/regenerate.

Database/import errors:

- Use transactions for import.
- Show clear failure messages.
- Do not partially overwrite existing data on failed import.

## Testing Strategy

Unit tests:

- AI response JSON parser.
- State delta merge logic.
- Backup export/import serialization.
- Provider request construction.

Widget tests:

- Chat page renders messages and choices.
- Settings page validates required fields.
- Conversation list creates and opens saves.

Manual tests:

- Configure API endpoint and send a test prompt.
- Create a conversation and receive choices.
- Tap a choice and confirm state changes.
- Export backup, delete local data if safe, then import backup.
- Confirm API key is not present in exported JSON.

## Open Decisions for Implementation Plan

These can be decided during implementation planning if not already fixed:

- Exact Flutter project name/package ID.
- Exact app display name.
- Whether to use `http`, `dio`, or another networking package.
- Exact Drift schema migrations structure.
- Whether backups are selected via Android storage access framework or a simpler file picker plugin.

## Acceptance Criteria for MVP

- Android Flutter app builds and runs locally.
- User can configure Base URL, API Key, and Model.
- User can create a conversation with 初雪.
- User can send a free-text message.
- App can call an OpenAI-compatible endpoint.
- Valid JSON AI replies render as character messages plus choices.
- Tapping a choice sends it as the next user action.
- `affection`, `mood`, `scene`, `time_slot`, and `flags` persist per conversation.
- Malformed AI replies are displayed as raw text instead of crashing or blocking the chat.
- Conversations persist locally after app restart.
- Backup export/import works and does not export API Key by default.
