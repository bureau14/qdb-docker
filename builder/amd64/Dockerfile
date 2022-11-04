FROM amazonlinux:2.0.20220606.1 as base

FROM base AS gcc-builder

RUN yum install -y bzip2
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y tar
RUN yum install -y xz
RUN yum install -y make
RUN yum install -y gzip

RUN mkdir -p /tmp/gcc-install
RUN mkdir -p /tmp/gcc-source
RUN mkdir -p /tmp/gcc-build

WORKDIR /tmp/gcc-source
RUN curl -sSL "https://s3.eu-central-1.amazonaws.com/qdbbuilddeps/linux/gcc/gcc-11.1.0.tar.xz" | tar x --xz --strip=1
RUN ./contrib/download_prerequisites

WORKDIR /tmp/gcc-build
RUN /tmp/gcc-source/configure --enable-languages=c,c++ --enable-lto --disable-multilib --prefix /tmp/gcc-install
RUN make -j72
RUN make -j72 install

FROM base AS ninja

RUN yum install -y wget
RUN yum install -y unzip

WORKDIR /tmp
RUN wget -N "https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip"  -O ninja-linux.zip
RUN unzip -d /usr/local/bin/ -n ninja-linux.zip
RUN chmod 755 /usr/local/bin/ninja
RUN rm ninja-linux.zip

FROM base

RUN yum install -y sudo
RUN yum install -y shadow-utils
RUN yum upgrade -y --skip-broken
# RUN sudo yum install -y amazon-linux-extras yum-utils

ENV TC_USER=teamcity
RUN /usr/sbin/adduser --comment "TeamCity" --home-dir /home/$TC_USER $TC_USER

ENV HOMEDIR=/home/$TC_USER

RUN yum install -y binutils
RUN yum install -y git
RUN yum install -y glibc-devel
RUN yum install -y openssl-devel
RUN yum install -y openssl-static
RUN yum install -y python3
RUN yum install -y python3-devel
RUN yum install -y python3-pip
RUN yum install -y python3-wheel
RUN yum install -y python3-setuptools
RUN yum install -y tar
RUN yum install -y xz
RUN yum install -y make
RUN yum clean all

ENV GOROOT=/usr/local/go1.17
ENV GOPATH=$HOMEDIR/go1.17

RUN mkdir -p $GOROOT
RUN curl -sSL "https://dl.google.com/go/go1.17.8.linux-amd64.tar.gz" | tar --strip-components=1 -xzf - -C $GOROOT

WORKDIR /usr/local
RUN curl -sSL "https://qdbbuilddeps.s3.eu-central-1.amazonaws.com/linux/cmake/cmake-3.20.4-linux-x86_64.tar.gz" | tar xz --gzip --strip=1


ENV PATH=$PATH:/usr/local/go1.17/bin

# Get boringssl dependencies
RUN mkdir -p $GOPATH/src/boringssl
WORKDIR $GOPATH/src/boringssl
RUN go mod init
RUN go mod edit -require golang.org/x/crypto@v0.0.0-20210513164829-c07d793c2f9a
RUN go mod edit -require golang.org/x/net@v0.0.0-20210614182718-04defd469f4e
RUN go get -v ./...

COPY --from=ninja /usr/local/bin/ninja /usr/local/bin/ninja
COPY --from=gcc-builder /tmp/gcc-install gcc-install
RUN cp -R gcc-install/* /usr/local/
RUN rm -Rf gcc-install
RUN ln -fs /usr/local/bin/gcc /usr/local/bin/cc
RUN ln -fs /usr/local/bin/g++ /usr/local/bin/c++
RUN echo '/usr/local/lib64' > sudo tee /etc/ld.so.conf.d/local-lib64.conf > /dev/null
RUN sudo ldconfig -v
