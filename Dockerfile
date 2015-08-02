FROM tutum/mongodb:3.0

ENV REPLICA_SET_NAME rs0
ENV REPLICA_SET_HOSTS 127.0.0.1

ADD run.sh /run.sh
RUN chmod a+x /run.sh