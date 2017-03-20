FROM nginx:1.11.10

ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/blockuseragents.rules /etc/nginx/blockuseragents.rules
ADD nginx/dhparam.pem /etc/nginx/ssl/
ADD nginx/ssl/* /etc/nginx/ssl/

EXPOSE 443 80
