FROM nginx:latest

RUN rm -f /etc/nginx/conf.d/default.conf

COPY ./files/tomcat.conf /etc/nginx/conf.d/

EXPOSE 80
EXPOSE 3000

ENTRYPOINT /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf 
