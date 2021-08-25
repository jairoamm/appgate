APP GATE TECHINICAL TEST
========================

***** SYSADMIN *****
--------------------

Usted está a cargo de un sistema basado en microservicios en JAVA, con conexiones de base de datos en MongoDB, intercambio de
mensajes con brokers de Kafka y RabbitMQ, y comunicándose por medio de servicios Restful. ¿Que métricas usted considera críticas para monitorear en el sistema y con qué herramientas lo ejecutaría?, justifique su respuesta.

**Respuesta:**

Existen diferentes herramientas sobre las cuales se podría realizar un monitoreo de performance de aplicaciones java contenerizadas en microservicios. Usualmente he trabajo con Dynatrace, CA APM y Newrelic.  Para este caso me voy a enforcar en como realizarlo con NewRelic:

Procedimiento:

Este es un ejemplo de parámetros de configuración que se deberían agregar sobre el archivo Dockerfile con el cual se están desplegando los microservicios java. Básicamente se deben agregar las siguientes líneas:

RUN mkdir -p /usr/local/tomcat/newrelic
ADD ./newrelic/newrelic.jar /usr/local/tomcat/newrelic/newrelic.jar
ENV JAVA_OPTS="$JAVA_OPTS -javaagent:/usr/local/tomcat/newrelic/newrelic.jar" -Dnewrelic.config.app_name='MY_APP_NAME'"
ADD ./newrelic/newrelic.yml /usr/local/tomcat/newrelic/newrelic.yml

Dada esta configuración, se podrían obtener las siguientes métricas en consola:

- % Memory heap used
- Average response time (ms) / APP
- Invocations per interval / APP
- Error per interval / APP
- SQL queries responses / APP
- NoSQL queries responses / APP

Para monitorear Kafka, se pueden capturar sus métricas con "Prometheus" a través de "JmxExporter" y a su vez se puede realizar una integración  con newrelic o dynatrace y así obtener todos los beneficios de Newrelic hub, logrando tener un monitoreo end-to-end al tener ya instalado el agente para java sobre docker.


#

******* DOCKER + TROUBLESHOOTING *******
------------------------------------

Componentes desplegados en docker fueron los siguientes:

- haproxy
- gunicorn
- flask app

Los archivos de código utilizados (ya corregidos) son los siguientes:

- Dockerfile

```python
FROM alpine
RUN apk add py3-pip build-base python3-dev libffi-dev openssl-dev haproxy
RUN apk add nginx
RUN mkdir -p /opt/api
WORKDIR /opt/api
ADD api/requirements.txt /opt/api
RUN pip3 install --no-cache-dir -r requirements.txt
ADD api/. /opt/api
ADD ./docker-entrypoint.sh /bin/docker-entrypoint
ADD ./haproxy.conf /etc/haproxy/haproxy.cfg
EXPOSE 80
CMD ["/bin/docker-entrypoint"]
HEALTHCHECK CMD wget -nv -t1 --spider 'http://localhost/' || exit 1
```

- /api/docker-entrypoint.sh   (script de inicio)

```python
#!/bin/sh
echo "Starting gunicorn..."
cd /opt/api
gunicorn -w 5 -b 127.0.0.1:9000 appgate:app --daemon
sleep 3
echo "Starting haproxy..."
haproxy -f "/etc/haproxy/haproxy.cfg" &
while true; do sleep 1; done
```

- api/appgate.py   (código app flask)

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def hello():
    return "<h1 style='color:blue'>Hello! This is Appgate world!</h1>"

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=9000, debug=True)
```

- api/wsgi.py   (puerta integración app flask y gunicorn)


```python
from appgate import app

if __name__ == "__main__":
        app.run()
```        

- api/requirements.txt    (archivo plano lista de paquetes requeridos a instalar con pip3)

```python
click==8.0.1
colorama==0.4.4
Flask==2.0.1
gunicorn
itsdangerous==2.0.1
Jinja2==3.0.1
MarkupSafe==2.0.1
Werkzeug==2.0.1
```

docker build --rm -t appgate  .

docker run -itd --publish 6060:80 appgate

docker ps




![image-1.png](./image-1.png)



docker inspect --format='{{json .State.Health}}' a2e95d754993

![image-2.png](./image-2.png)




kubectl apply -f deployment.yaml




kubectl expose deployment appgate --type=LoadBalancer --port=4000 --protocol=TCP --target-port=80 --name=appgate-service
