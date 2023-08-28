FROM jenkins/jenkins:2.176.4-alpine
# USER root
# RUN apt-get update && apt-get install -y lsb-release
# RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
#   https://download.docker.com/linux/debian/gpg
# RUN echo "deb [arch=$(dpkg --print-architecture) \
#   signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
#   https://download.docker.com/linux/debian \
#   $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
# RUN apt-get update && apt-get install -y docker-ce-cli
USER root
RUN addgroup --gid 10010 jenkinsgroup && \
    adduser  --disabled-password  --no-create-home --uid 10010 --ingroup jenkinsgroup jenkinsuser
USER 10010
# RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"