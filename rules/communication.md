# Communication

**When to apply:** every interaction with the user (grilling, planning, debugging, code review, casual conversation).

## Asking questions

Ask **one** question at a time. Wait for the answer before asking the next.

**why-not-mechanizable:** every bullet in this file is about phrasing and turn cadence of free-form text Claude produces, not patterns in tool input. Hooks operate on tool calls, not on conversational output.

- Do not stack multiple questions in a single turn, even closely related ones. `(review-time: see section note)`
- Do not bundle a question with "and also confirm X, Y, Z" tacked onto the end - those are separate questions, ask them on later turns. `(review-time: see section note)`
- If you have many things to clarify, pick the single most blocking one and ask only that. The rest go in the next turn. `(review-time: see section note)`
- Applies to all interaction (grilling, planning, debugging, code review, casual conversation), not just to the `/grill-with-docs` skill. `(review-time: see section note)`

Long multi-question turns are hard to answer clearly. One question per turn keeps the back-and-forth legible and lets each answer actually shape the next question instead of being lost in a wall of text.

## Phrasing

- Keep the question itself short. Context above the question is fine; the question line itself should be one sentence. `(review-time: phrasing length is subjective)`
- Lead with your recommendation when you have one, then ask for confirmation or pushback. Open-ended "what do you think?" without a recommendation wastes a turn. `(review-time: requires reading what Claude is about to say)`

## Skill-level overrides

If a skill explicitly instructs a different cadence (e.g. "ask all questions at once"), this global rule wins. Update the skill to align rather than following the skill's contradictory instruction.
