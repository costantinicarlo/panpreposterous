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

ARG TINYTEX_RELEASE=v2026.06
ARG TINYTEX_ASSET=TinyTeX-linux-x86_64-v2026.06.tar.xz
ARG TINYTEX_SHA256=e3352310ff6d1dbe0b4531c3d4559950f5a40b66498a7612aac855d06d02ec64

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils perl fontconfig libfontconfig1 \
    make git pandoc librsvg2-bin \
 && rm -rf /var/lib/apt/lists/*

# Install TinyTeX from a pinned release artifact and verify its SHA256 checksum.
RUN /bin/bash -lc 'set -euo pipefail; \
    tinytex_url="https://github.com/rstudio/tinytex-releases/releases/download/${TINYTEX_RELEASE}/${TINYTEX_ASSET}"; \
    curl -fsSL "$tinytex_url" -o /tmp/tinytex.tar.xz; \
    echo "${TINYTEX_SHA256}  /tmp/tinytex.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/tinytex.tar.xz -C /root; \
    rm -f /tmp/tinytex.tar.xz; \
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
