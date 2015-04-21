FROM centos:centos7
MAINTAINER Josue Lima <josuedsi@gmail.com>

#  Simple rails image running app for test purposes

RUN yum update -y &&                           \
    yum groups mark convert &&                 \
    yum -y groupinstall "Development Tools" && \
    yum install -y        \
      epel-release        \
      tar                 \
      make                \
      gcc gcc-c++         \
      zlib                \
      zlib-devel          \
      pcre-devel git      \
      ruby 2.2.1          \
      ruby-devel          \
      libsqlite3-dev      \
      sqlite-devel        \
      sqlite3             \
      nodejs              \
      rubygem-nokogiri && \
    yum clean all

# Create user to run app
RUN groupadd staff --gid 6156 && \
    useradd --home /staff --create-home --uid 6157 --gid 6156 staff

# Run stuff as staff from now on
USER staff

WORKDIR /staff/
RUN mkdir logs

# Copy .gemrc settings. All gems will be installed without docs
ADD .gemrc /staff/

# Clone project
RUN git clone --depth=1 https://github.com/josuelima/docker_ecs.git
WORKDIR /staff/docker_ecs/

# Install bundle and config gems folder (bin)
RUN gem install bundle
ENV PATH /staff/bin:$PATH
RUN bundle install

# Compile assets
RUN bundle exec rake assets:precompile

# Run app
CMD thin -C thin.yml start && tail -F /staff/docker_ecs/log/production.log