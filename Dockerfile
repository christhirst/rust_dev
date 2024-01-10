# x86_64
FROM rust:slim-buster

# Non-Rust tooling
ENV TZ=US/New_York
RUN mkdir /var/run/sshd
RUN apt-get update -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    pkg-config \
    rr \
    tree \
    xxd \
    git \
    vim \
    openssh-server

RUN sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config
RUN sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config
# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;
ENV ROOT_PASSWORD root
RUN mkdir /var/run/sshd

#RUN echo ‘root:PASS!wo#rd’ | chpasswd

#RUN sed -i ‘s/#PermitRootLogin prohibit-password/PermitRootLogin yes/’ /etc/ssh/sshd_config

#RUN sed ‘s@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g’ -i /etc/pam.d/sshd
RUN echo 'root:root123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Rust tooling
RUN rustup toolchain install nightly
RUN rustup component add llvm-tools-preview
RUN cargo install mdbook
RUN cargo install cargo-fuzz
RUN cargo install cargo-binutils
RUN cargo install cargo-modules
RUN cargo install cargo-audit

# Src import
RUN mkdir /workspace
WORKDIR /workspace

EXPOSE 22
RUN ls -l /usr/sbin/sshd

ENTRYPOINT ["entry_point.sh"]
CMD    ["/usr/sbin/sshd", "-D", "-e"]
