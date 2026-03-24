# Opencode History Windowing Plan

Complexity: medium-high.

Why:
- The plugin currently assumes full-session render/replay.
- Output buffer text, render state, extmarks, and markdown rendering all assume the whole transcript is present.
- Safe prepend/evict behavior needs careful cursor, scroll, and line-mapping handling.

## Recommended implementation order

### Phase 1: Tail-only render
- Add a config value for rendered history limit, preferably by message count first.
- In the full replay/render path, only materialize the newest N messages.
- Show a top sentinel like `[older messages hidden]`.
- Keep the full canonical session in session/state tables.

Goal:
- Preserve Treesitter and render-markdown.
- Bound buffer size, extmarks, and render-state growth.

### Phase 2: Manual older-history loading
- Add a command or keybinding to prepend one older chunk.
- Track rendered chunks explicitly.
- Preserve scroll position when prepending.
- Keep the sentinel when more history remains.

Goal:
- Make older context available without full replay.

### Phase 3: Automatic top-triggered prepend
- Detect when cursor/viewport reaches the top sentinel.
- Prepend one older chunk automatically.
- Debounce to avoid repeated prepends while scrolling.

Goal:
- Make history feel continuous.

### Phase 4: Chunk eviction / soft garbage collection
- Keep only a small sliding window of chunks resident.
- Suggested policy:
  - keep current chunk
  - keep one older chunk
  - keep one newer chunk
- If user moves away from older prepended chunks, evict after a short idle timeout.
- Rebuild buffer/render state from the retained chunk set.

Goal:
- Avoid immediate re-fetch/re-render churn while still releasing memory quickly.

## Key technical areas to patch

- Full replay path in the renderer.
- Render-state line indexing and part/message bookkeeping.
- Buffer write/update routines.
- Scroll preservation when prepending/removing chunks.
- Extmark rebuild strategy for chunked history.
- Top sentinel UX and load-more trigger.

## Suggested first patch

Implement only Phase 1 first:
- render last N messages
- add top sentinel
- no lazy loading yet

This is the highest-impact, lowest-risk step and should cut RAM usage substantially before chunk prepend/eviction is added.

## Risks

- Prepending older chunks can break line-index assumptions.
- Eviction must not leave stale extmarks or stale part-to-line mappings.
- Streaming updates must continue to work correctly while only the tail is rendered.
- Jump-to-message/reference behavior may need to account for unloaded history.

## Success criteria

- Large sessions no longer cause runaway RAM use.
- Recent conversation remains fully rendered with Treesitter and render-markdown.
- Older history is recoverable on demand.
- Scrolling and message streaming remain stable.
