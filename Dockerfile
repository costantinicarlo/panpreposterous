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
ENV PANPREPOSTEROUS_ROOT=/opt/panpreposterous
ENV PANPREPOSTEROUS_TEMPLATE_DIR=/opt/panpreposterous/template
ENV PANPREPOSTEROUS_FILTERS_DIR=/opt/panpreposterous/filters
ENV PANPREPOSTEROUS_TEMPLATE_PATH=/opt/panpreposterous/template/preprint_template_xe_citeproc.tex
ENV PANPREPOSTEROUS_BACKMATTER_FILTER_PATH=/opt/panpreposterous/filters/backmatter.lua
ENV PANPREPOSTEROUS_SUPPLEMENTARY_FILTER_PATH=/opt/panpreposterous/filters/supplementary.lua
ENV PANPREPOSTEROUS_MERMAID_FILTER_PATH=/opt/panpreposterous/filters/mermaid.lua

ARG TINYTEX_RELEASE=v2026.06
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils perl fontconfig libfontconfig1 \
    make git pandoc librsvg2-bin \
    nodejs npm \
 && rm -rf /var/lib/apt/lists/*

# Install mermaid-cli globally for Mermaid diagram rendering
RUN npm install -g @mermaid-js/mermaid-cli@10.6.1 && npm cache clean --force

# Install TinyTeX from a pinned release artifact and verify its SHA256 checksum.
RUN /bin/bash -lc 'set -euo pipefail; \
        target_arch="${TARGETARCH:-}"; \
        if [[ -z "$target_arch" ]]; then \
            target_arch="$(dpkg --print-architecture)"; \
        fi; \
        case "$target_arch" in \
            amd64) \
                tinytex_asset="TinyTeX-linux-x86_64-${TINYTEX_RELEASE}.tar.xz"; \
                tinytex_sha256="e3352310ff6d1dbe0b4531c3d4559950f5a40b66498a7612aac855d06d02ec64"; \
                ;; \
            arm64) \
                tinytex_asset="TinyTeX-linux-arm64-${TINYTEX_RELEASE}.tar.xz"; \
                tinytex_sha256="c1de2da2783fe628656fd4da104459f8026d3eb1b8428b676ad814b018e55845"; \
                ;; \
            *) \
                echo "Unsupported TARGETARCH: $target_arch. Supported values: amd64, arm64" >&2; \
                exit 1; \
                ;; \
        esac; \
        tinytex_url="https://github.com/rstudio/tinytex-releases/releases/download/${TINYTEX_RELEASE}/${tinytex_asset}"; \
    curl -fsSL "$tinytex_url" -o /tmp/tinytex.tar.xz; \
        echo "${tinytex_sha256}  /tmp/tinytex.tar.xz" | sha256sum -c -; \
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
COPY template ${PANPREPOSTEROUS_TEMPLATE_DIR}
COPY filters ${PANPREPOSTEROUS_FILTERS_DIR}
COPY bin/panpreposterous /usr/local/bin/panpreposterous
RUN chmod +x /usr/local/bin/panpreposterous

# Let TeX search the template dir (// = search subdirs; trailing : keeps defaults)
ENV TEXINPUTS=${PANPREPOSTEROUS_TEMPLATE_DIR}//:

CMD ["panpreposterous", "--help"]
