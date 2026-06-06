# Panpreposterous: pandoc-only reproducible PDF builder
# Minimal Debian + Pandoc + TinyTeX (XeLaTeX) + just-needed TeX packages

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils wget perl fontconfig libfontconfig1 \
    make git pandoc \
 && rm -rf /var/lib/apt/lists/*

# Install TinyTeX (admin mode) and add symlinks to /usr/local/bin
RUN /bin/bash -lc "wget -qO- https://yihui.org/tinytex/install-bin-unix.sh | sh -s - --admin --no-path" && \
    /root/.TinyTeX/bin/*/tlmgr path add

# Ensure tlmgr in PATH for all arches
ENV PATH="/root/.TinyTeX/bin/x86_64-linux:/root/.TinyTeX/bin/x86_64-linuxmusl:/root/.TinyTeX/bin/aarch64-linux:${PATH}"

# Install collections that cover all needed packages
RUN /root/.TinyTeX/bin/*/tlmgr install \
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
