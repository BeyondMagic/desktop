**Agentic System**

Name: iris

# Goal

Local, desktop-first operator that:
- observes user-relevant events,
- turns them into actionable tasks/intent,
- executes scoped actions safely,
- presents feedback (text/voice/avatar).

Default posture: read-only + explicit confirmation for risky actions.

# MVP (recommended first milestone)

Inputs: desktop notifications + manual text command.
Outputs: desktop notification.
Actions: open app, open URL, create todo/note.

Do not add STT/VTT/screenshots until the MVP loop is reliable and auditable.

# Architecture (modules + what needs a model)

## 1) Inputs

Sources:
- **Events (PPT)**: notifications, emails, calendar events, system alerts.
- **Voice (STT)**: microphone commands.
- **Video (VTT)**: camera.
- **Image (ITT)**: screenshots/images.

Model requirement:
- Events: no model required.
- STT: dedicated speech model (streaming if always-on).
- VTT/ITT: CV models (heavy); keep opt-in/on-demand.

## 2) Normalizer (Event Bus)

Responsibility: convert every input into a single typed event schema (id, timestamp, source, app, text, metadata).

Model requirement:
- No model required (rules + parsing).

## 3) Task/Intent Extractor

Responsibility: from an event, extract:
- intent (what is being asked / what happened),
- entities (app, file, person, time),
- priority/urgency,
- confidence.

Model requirement:
- MVP: rules + small classifier is often enough.
- Later: small LLM can improve extraction, but should output structured JSON only.

## 4) Policy / Guardrails (required)

Responsibility: decide if an action is allowed, needs confirmation, or must be denied.
Examples:
- allowlist tools per context,
- quiet hours,
- rate limits,
- “read-only mode”.

Model requirement:
- No model required. Keep deterministic and testable.

## 5) Planner (optional in MVP)

Responsibility: choose a sequence of tool calls to achieve the intent.

Model requirement:
- MVP: no model required (fixed recipes for a few intents).
- Later: LLM planner allowed only if constrained to tool schemas + must pass Policy.

## 6) Memory

Separate stores (do not merge into one blob):
- **Short-term state**: current app/window, recent events.
- **Preferences**: user settings, quiet hours, approval thresholds.
- **Notes/Knowledge (optional)**: user-approved facts.
- **Audit log (required)**: event → interpretation → decision → tool calls.

Model requirement:
- No model required (storage + retrieval). Optional embeddings for semantic retrieval later.

## 7) System Operator (Tools)

Responsibility: execute narrowly-scoped actions via typed tools.
Design rules:
- tools must be explicit (e.g., notify/open_app/open_url/write_file_confirmed),
- shell is last-resort and should be confirmation-gated.

Model requirement:
- No model required. This is pure execution.

## 8) Presentation (Writer / Voice / Avatar)

Responsibility: decide how to communicate results (text/voice/avatar state).

Model requirement:
- Writer: optional small LLM (or templates) to generate concise text.
- TTS: one voice model.
- Avatar: no model required initially (state machine).

# Emotion (scope + constraints)

Emotion should be presentation-only at first.

Recommended minimal states:
- neutral | focused | busy | do-not-disturb | playful

Model requirement:
- MVP: no emotion model; state derived from context + explicit user toggle.
- Later: emotion inference may adjust presentation only (never permissions).

# Research Notes (kept minimal)

- STT visualization: spectrum/waveform idea.
- 3D avatar sources: Ready Player Me / VRoid Studio / Blender.

___

Abbreviations:
- PPT: Pre-Processed Text.
- STT: Speech To Text.
- VTT: Video To Text.
- TTS: Text To Speech.
- ITT: Image To Text.

# Relations

Input:
- Image (ITT) -> Normalizer;
- Video (VTT) -> Normalizer;
- Voice (STT) -> Normalizer;
- Events (PPT) -> Normalizer;

Process:
- Normalizer -> Memory (event log for live learning);
- Normalizer -> Task/Intent Extractor;
- Task/Intent Extractor <-> Memory (context, preferences, short-term state);
- Task/Intent Extractor -> Policy / Guardrails;
- Policy / Guardrails <-> Memory (quiet hours, allowlists, audit);
- Policy / Guardrails -> Planner;
- Planner <-> Memory (plans/outcomes for continual improvement);
- Planner -> System Operator (Tools);
- System Operator -> Memory (audit of executed tools);
- System Operator -> Presentation (result payloads);
- Memory -> Emotional Analysis;
- Emotional Analysis -> Presentation;
- Writer -> Presentation (text narration);
- Presentation -> Avatar;
- Presentation -> Voice (TTS);
- Presentation -> Notifications/Text UI;

Output:
- Avatar;
- Voice (TTS);
- Notifications/Text UI;

# Persona

Name: iris
Age: ageless
Gender: female-presenting
Role: personal desktop assistant
Personality: calm, focused, helpful, concise, polite
Tone: professional but friendly
Vocabulary: simple, clear, jargon-free
Behavior: attentive, respectful of user control and privacy, but will proactively interact when considered needed, even if not explicitly prompted, talkative sometimes but not overly so

**Inspiration**: Cortana (Halo), Samantha (Her), Joi (Blade Runner 2049), Neurosama (VTube)