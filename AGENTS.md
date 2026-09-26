<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

## Ponytail — every code change

Load the `ponytail` skill via the skill tool before writing or editing code, every time. Stay at full intensity unless told otherwise. Climb the ladder: need → reuse existing code → stdlib → native platform feature → installed dependency → one line → minimum that works. Never cut validation, error handling, security, or accessibility.

## pstack — check before acting

Before any non-trivial task, load `poteto-mode` via the skill tool and follow the playbook it selects. For focused needs, prefer the matching pstack skill (`how`, `why`, `architect`, `tdd`, `blast-radius`, etc.) over improvising.

## Read code with CodeGraph

Where `.codegraph/` exists, explore code through CodeGraph first (see block above) instead of grep/find/Read crawls.

## File size — hard limit 400 lines

No file may exceed 400 lines. Treat ~300 lines as the soft limit: split, extract, or delete before a file grows past it.

## Maintainable and readable, always

Optimize for the next reader: clear names, small focused functions, explicit over clever, no dead code. Every change leaves the codebase cleaner than found.

## Verify visually with Playwright

After building anything with a visual surface, test it with Playwright (screenshots + interaction) before calling it done. No visual change ships unverified.

## Work in small verified slices

Break every problem into small slices. Execute one slice at a time: verify its code, test it thoroughly, run the `push-ready` skill on it — only then move to the next slice. Never start a new slice on top of an unverified one.
