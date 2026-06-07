# Panpreposterous: pandoc-only reproducible PDF builder
# Minimal Debian + Pandoc + TinyTeX (XeLaTeX) + just-needed TeX packages

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="panpreposterous" \
    org.opencontainers.image.description="Pandoc + XeLaTeX container for reproducible preprint/postprint PDFs" \
    org.opencontainers.image.url="https://github.com/costantinicarlo/panpreposterous" \
    org.opencontainers.image.source="https://github.com/costantinicarlo/panpreposterous" \
    org.opencontainers.image.licenses="CC-BY-4.0"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils wget perl fontconfig libfontconfig1 \
    make git pandoc \
 && rm -rf /var/lib/apt/lists/*

# Install TinyTeX and expose its binaries via stable symlinks in /usr/local/bin.
RUN /bin/bash -lc 'set -euo pipefail; \
    wget -qO- https://yihui.org/tinytex/install-bin-unix.sh | sh -s -- "" --no-path; \
    tinytex_bin="$(find /root/.TinyTeX/bin -mindepth 1 -maxdepth 1 -type d | head -n 1)"; \
    test -n "$tinytex_bin"; \
    ln -sf "$tinytex_bin"/* /usr/local/bin/'

# Install collections that cover all needed packages
RUN tlmgr install \
    collection-latex \
    collection-latexrecommended \
    collection-latexextra \
    collection-fontsrecommended \
    collection-xetex \
    latexmk

WORKDIR /work
COPY template /opt/panpreposterous/template
COPY filters /opt/panpreposterous/filters
COPY bin/panpreposterous /usr/local/bin/panpreposterous
RUN chmod +x /usr/local/bin/panpreposterous

# Let TeX search the template dir (// = search subdirs; trailing : keeps defaults)
ENV TEXINPUTS=/opt/panpreposterous/template//:

CMD ["panpreposterous", "--help"]
