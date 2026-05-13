FROM fedora:43

ARG GID=1000
ARG UID=1000

RUN dnf install -y \
    graphviz \
    make \
    bash \
    curl \
    pandoc \
    texlive-xetex \
    texlive-collection-latexextra \
    dejavu-sans-fonts \
    dejavu-serif-fonts \
    dejavu-sans-mono-fonts \
    wkhtmltopdf \
    && dnf clean all

RUN mkdir /home/builder
RUN chown "$GID:$UID" /home/builder

USER "$GID:$UID"
ENV HOME=/home/builder
ENV XDG_RUNTIME_DIR=/home/builder