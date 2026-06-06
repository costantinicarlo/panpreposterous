# Workspace instructions for Copilot

## General working rules

- Treat this workspace as a research-oriented, reproducible project.
- Prefer small, explicit, reviewable changes over broad rewrites.
- Do not silently change data, scientific assumptions, statistical models, or file formats.
- Before editing, inspect the relevant files and infer the existing conventions.
- When uncertain, state the uncertainty rather than inventing details.

## Output format for agentic work

When reporting results of an agentic task, use this structure:

1. **What changed**
   - Briefly list modified files and the purpose of each change.

2. **Why**
   - Explain the reasoning in practical terms.

3. **How to verify**
   - Provide exact commands to run, such as tests, render commands, linting, or checks.

4. **Risks or assumptions**
   - Mention anything that was inferred, untested, or potentially fragile.

Do not produce long narrative explanations unless explicitly requested.

## Coding style

- Prefer readable, explicit code over clever compact code.
- Keep functions small and named according to their biological/statistical purpose.
- Add comments only where they clarify non-obvious reasoning.
- Avoid adding new dependencies unless they are clearly justified.

## Reproducibility

- Preserve relative paths when possible.
- Prefer scripted workflows over manual GUI steps.
- When generating derived files, document the source files and commands used.