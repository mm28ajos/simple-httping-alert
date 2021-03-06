FROM debian:10.7-slim

#create app folder
ENV APP_HOME=/opt/simplehttpingalert/
ENV ENTRYPOINT=${APP_HOME}entrypoint.sh
ENV THREAD=${APP_HOME}thread.sh
WORKDIR $APP_HOME

# install mail, tzdata and httping
RUN apt update && apt install tzdata msmtp httping -y 

# copy files
COPY entrypoint.sh thread.sh ./
COPY msmtprc.conf /root/.msmtprc

# set permissions of entrypoint script
RUN chmod +x ${ENTRYPOINT} ${THREAD}

# CMD
ENTRYPOINT ${ENTRYPOINT}
