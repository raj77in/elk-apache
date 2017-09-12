FROM java:8
MAINTAINER Amit Agarwal <amit.agarwal@mobileum.com>
# Idea borrowed from https://hub.docker.com/r/willdurand/elk/

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y supervisor curl && \
    apt-get clean

# Elasticsearch
RUN \
    	apt-get update && \
    	wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    	apt-get install apt-transport-https net-tools && \
    	echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" > /etc/apt/sources.list.d/elastic-5.x.list && \
    	apt-get update &&  apt-get install logstash kibana elasticsearch && \
	apt-get clean

ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf
ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/logstash.conf

# Logstash plugins
# RUN /usr/share/logstash/bin/logstash-plugin install logstash-filter-translate

ADD etc/supervisor/conf.d/kibana.conf /etc/supervisor/conf.d/kibana.conf
ADD etc/logstash/el_template.json /etc/logstash/el_template.json
ADD etc/logstash/conf.d/logstash-simple.conf /etc/logstash/conf.d/logstash-simple.conf

EXPOSE 80

ENV PATH /usr/share/logstash/bin/:$PATH
# RUN sed -i '/network.host/ s/.*/network.host: 127.0.0.1/' /etc/elasticsearch/elasticsearch.yml
# RUN sed -i '/bind.host/ s/.*/bind.host: 127.0.0.1/' /etc/elasticsearch/elasticsearch.yml
# RUN sed -i '/http.port: 9200/ s/.*/http.port: 9200/' /etc/elasticsearch/elasticsearch.yml
# RUN sed -i '/#transport.tcp.port/ s/.*/transport.tcp.port: 9300/' /etc/elasticsearch/elasticsearch.yml
# RUN sed  '/'$(hostname)'/ s/.*/127.0.0.1 '$(hostname)'/' /etc/hosts >/etc/hosts.new && mv /etc/hosts.new /etc/hosts

## CHeck with curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'

# Kibana
RUN sed -i 's/.*server.port: 5601/server.port: 80/' /etc/kibana/kibana.yml
RUN sed -i '/#server.host: "localhost"/ s/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml


CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]

