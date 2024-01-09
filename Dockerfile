# x86_64
FROM rust:1.75-slim

# Non-Rust tooling
ENV TZ=US/New_York
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

RUN mkdir /var/run/sshd

#RUN echo ‘root:PASS!wo#rd’ | chpasswd

#RUN sed -i ‘s/#PermitRootLogin prohibit-password/PermitRootLogin yes/’ /etc/ssh/sshd_config

#RUN sed ‘s@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g’ -i /etc/pam.d/sshd

EXPOSE 22


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

CMD [“/usr/sbin/sshd”, “-D”]

