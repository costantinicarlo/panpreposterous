# Naming and typography policy

This document defines the canonical naming and typographic conventions for Panpreposterous. These conventions apply to the documentation, manuscript text, repository metadata, examples, command-line instructions, software comments, release notes, and citation guidance.

## 1. Canonical project name

The canonical prose name of the project is:

**Panpreposterous**

Use **Panpreposterous** when referring to the project as a whole, the toolkit, the software ecosystem, the documentation corpus, the design philosophy, the publication workflow, or the citable software work.

Examples:

* Panpreposterous is a reproducible manuscript-production toolkit.
* Panpreposterous supports multiple typesetting backends.
* The Panpreposterous documentation describes the Markdown-to-publication workflow.
* Please cite Panpreposterous when using the toolkit to prepare scholarly outputs.

The name **Panpreposterous** should be treated as a proper software name in prose. It should be capitalised at the beginning of the word, including in titles, headings, abstracts, captions, keyword sections, and sentence-initial position.

## 2. Canonical command name

The canonical command-line name is:

`panpreposterous`

Use `panpreposterous` in monospace whenever referring to the executable command, runtime entry point, Docker command, script name, package/module identifier, repository slug, image-name component, configuration key, file path, directory name, literal string, or any other computational object whose exact spelling matters.

Examples:

* The Docker container runs the `panpreposterous` command at runtime.
* Invoke the toolkit with `panpreposterous build`.
* The repository slug is `panpreposterous`.
* The Docker image may expose `panpreposterous` as its entry-point command.
* The configuration file may include a `panpreposterous` section.
* The source tree contains scripts used by `panpreposterous`.

Do not capitalise the command as `Panpreposterous`. Do not typeset the command in italics or boldface. Use Markdown backticks in source documents and `\texttt{panpreposterous}` in LaTeX output when writing the command literally.

## 3. Project name versus command name

Distinguish the project from the command.

Use **Panpreposterous** when the sentence refers to the toolkit, project, software work, documentation, citation target, or development effort.

Use `panpreposterous` when the sentence refers to something executed, typed, parsed, named in the file system, invoked by Docker, passed to a shell, stored in a configuration file, or otherwise treated as a literal identifier.

Examples:

* Panpreposterous provides a backend-agnostic publication workflow.
* The `panpreposterous` command dispatches the selected backend.
* Panpreposterous can support both LaTeX and Typst backends.
* The container entry point calls `panpreposterous`.
* Panpreposterous is cited as software; `panpreposterous` is invoked as a command.

## 4. Titles, headings, abstracts, and keywords

Use **Panpreposterous** in human-readable titles, headings, abstracts, and keyword lists when referring to the project.

Examples:

* Design Principles of Panpreposterous
* Panpreposterous as a Backend-Agnostic Manuscript Toolkit
* Keywords: Panpreposterous; Pandoc; LaTeX; Typst; preprint; postprint; reproducible publishing

Use `panpreposterous` in titles or headings only when the heading explicitly refers to the command or another literal identifier.

Examples:

* The `panpreposterous build` command
* Runtime behaviour of `panpreposterous`
* Configuration keys under `panpreposterous`

## 5. External software names

Use the established prose names of external tools, languages, engines, platforms, and ecosystems when referring to them conceptually.

Preferred prose forms include:

* Pandoc
* Markdown
* YAML
* CSL
* BibTeX
* LaTeX
* XeLaTeX
* LuaLaTeX
* XeTeX
* Typst
* Docker
* GitHub

Use monospace only when referring to literal commands, file extensions, filenames, paths, options, image names, package names, configuration keys, or code fragments.

Examples:

* Panpreposterous uses Pandoc.
* The command calls `pandoc`.
* Panpreposterous can produce PDF output through LaTeX.
* The default executable may be `xelatex`.
* The metadata file is `metadata.yaml`.
* Bibliographic records are stored in `references.bib`.
* The citation style file is `journal.csl`.
* The Docker build uses `docker build`.

## 6. LaTeX logo macros

In Markdown source, write plain prose names:

* LaTeX
* XeLaTeX
* LuaLaTeX
* XeTeX
* BibTeX

Do not require authors to write raw LaTeX logo macros such as `\LaTeX{}`, `\XeLaTeX{}`, or `\BibTeX{}` in ordinary Markdown source.

The rendering layer may optionally convert these names to typographic logo macros in PDF output. This is a template-level decision, not an authoring requirement.

The source document should remain portable across PDF, HTML, DOCX, GitHub Markdown, and plain-text contexts.

## 7. Italics, boldface, and quotation marks

Do not italicise **Panpreposterous** in ordinary prose.

Do not italicise `panpreposterous`.

Use boldface only when required by the surrounding document structure, such as in a heading, table header, or UI label.

Do not place the project name or command name in quotation marks unless the grammar of the sentence specifically discusses the word as a word.

Examples:

* Correct: Panpreposterous is distributed as a containerised toolkit.
* Correct: The command is `panpreposterous`.
* Avoid: *Panpreposterous* is distributed as a containerised toolkit.
* Avoid: “Panpreposterous” is distributed as a containerised toolkit.
* Avoid: The command is **panpreposterous**.

## 8. Repository, package, image, and file-system names

Use lowercase monospace for technical identifiers, including repository slugs, package names, Docker images, paths, directories, filenames, extensions, and configuration keys.

Examples:

* `panpreposterous`
* `panpreposterous-latex`
* `panpreposterous-typst`
* `panpreposterous.yml`
* `metadata.yaml`
* `.github/workflows/build.yml`
* `Dockerfile`
* `docker compose`
* `ghcr.io/.../panpreposterous`

When such identifiers occur inside prose, preserve their exact spelling and wrap them in backticks.

## 9. Backend names

Backend names should distinguish between conceptual backends and implementation identifiers.

Use prose names for backend technologies:

* LaTeX backend
* Typst backend
* HTML backend
* DOCX backend

Use monospace for backend identifiers, configuration values, image suffixes, or command-line arguments.

Examples:

* Panpreposterous supports a LaTeX backend and may support a Typst backend.
* Select the backend with `--backend latex`.
* A future backend value may be `typst`.
* The LaTeX backend may use the image `panpreposterous-latex`.
* The Typst backend may use the image `panpreposterous-typst`.

## 10. Citation policy

When citing the software project, cite **Panpreposterous**, not `panpreposterous`.

Recommended prose:

> We prepared the manuscript using Panpreposterous, a containerised, Pandoc-centred toolkit for reproducible preprint and postprint production.

Recommended bibliography title:

> Panpreposterous: A containerised toolkit for reproducible preprint and postprint production

Use the capitalised prose name in citation metadata, including `CITATION.cff`, Zenodo records, GitHub release titles, software documentation, and manuscript references.

Use lowercase monospace only when the citation text specifically discusses the command, repository slug, image name, or executable.

Examples:

* Correct: Please cite Panpreposterous.
* Correct: The software work is titled “Panpreposterous”.
* Correct: The runtime command is `panpreposterous`.
* Avoid: Please cite `panpreposterous`.
* Avoid: The software work is titled “panpreposterous”, unless the release metadata deliberately defines the lowercase identifier as the formal title.

## 11. First mention

At first mention in documentation or scholarly prose, define both the project and the command if relevant.

Recommended form:

> Panpreposterous is a containerised toolkit for reproducible manuscript production. Its runtime command is `panpreposterous`.

For backend-specific documentation:

> Panpreposterous dispatches backend-specific build workflows through the `panpreposterous` command.

## 12. Summary rule

Use **Panpreposterous** for the project.

Use `panpreposterous` for the command or any literal computational identifier.

Use established prose names for external technologies, such as Pandoc, LaTeX, XeLaTeX, Typst, Docker, and GitHub.

Use monospace for commands, filenames, paths, options, configuration keys, package names, image names, and exact strings.

When in doubt, ask whether the word is being used as a human-readable name or as a machine-readable token. Human-readable names use prose typography. Machine-readable tokens use monospace.
