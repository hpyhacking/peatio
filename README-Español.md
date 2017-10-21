Un exchange de cripto divisas Open-Source
=====================================

**Soporte en Español no oficial con libre interpretación**

[![Code Climate](https://codeclimate.com/github/peatio/peatio.png)](https://codeclimate.com/github/peatio/peatio)
[![Build Status](https://travis-ci.org/peatio/peatio.png?branch=master)](https://travis-ci.org/peatio/peatio)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/peatio/peatio?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Peatio es un software libre y open-source para implementar una Exchange de criptodivisas usando el framework de Rails junto con otras tecnologias de vanguardia.

### Misión

Nuestra misión es construir el mejor intercambio de divisas criptográficas de código abierto con un motor de negociación de alto rendimiento y seguridad que los usuarios puedan confiar y disfrutar. Además, queremos mover la tecnología de intercambio de moneda criptopedera al proporcionar soporte y agregar nuevas características. Estamos ayudando a la gente a construir fácil su propio intercambio en todo el mundo.

Se agradece completamente la ayuda, por lo que eres libre de enviar tus pull-requests o problemas que puedes tener.

### Cosas que debes de saber

HACER UN EXCHANGE ES DIFICIL

Peatio lo hace facil, pero crear un exchange es mucho mas dificil que un blog, que puede descargar el código fuente y siguiendo la guía o incluso un instalador y boom cool! Un sitio de fantasía está ahí para obtener ganancias. Siempre priorizamos la seguridad y la velocidad superior a la configuración con un solo clic. Hemos dividido Peatio en muchos componentes (procesos) por lo que es flexible de implementar y escalable.

EL CONOCIMIENTO DE SEGURIDAD ES UN REQUISITO.

Peatio no puede proteger a sus clientes cuando la contraseña del administrador es 1234567, o abrir puertos sensibles al internet. Ejecutar un Exchange es una tarea muy arriesgada, porque se trata de dinero directamente. Sino sabe como hacer un Exchange seguro, mejor contratar a un experto.

Debes saber lo que estas haciendo, no hay atajos. Por favor, prepararse para continuar:

* Conocimiento en Rails,
* Conocimiento en seguridad informatica
* Administración del Sistema

### Caracteristicas

* Diseñado como Exchange de criptomonedas de alto rendimiento.
* Motor incorporado de alto rendimiento.
* Built-in [Proof of Solvency](https://iwilcox.me.uk/2014/proving-bitcoin-reserves) Audit
* Sistema incorporado de tickets para ayudar al cliente
* Usabilidad y Escabilidad
* Websocket API y soporte de comercio de alta frecuencia.
* Soporte de múltiples monedas digitales (por ejemplo, Bitcoin, Litecoin, Dogecoin etc).
* Fácil personalización del procesamiento de pagos tanto para monedas fiat como digitales.
* Autentificación por SMS y Google Two-Factor
* [Verificación KYC](http://en.wikipedia.org/wiki/Know_your_customer).
* Poderosa zona administrativa y herramientas de gestión
* Altamente configurable y extensible.
* Industry standard security out of box
* Comunidad activa detrás.
* Gratis y Open-Source
* Creado y mantenido por [Peatio open-source group](http://peatio,com)
* Soporte en español por [Shadow Myst](http://shadowmyst.net)

### Exchange conocidas que usan Peatio

* [Yunbi Exchange](https://yunbi.com) - A crypto-currency exchange funded by BitFundPE
* [One World Coin](https://oneworldcoin.com)
* [Bitspark](https://bitspark.io) - Bitcoin Exchange in Hong Kong
* [MarsX.io](https://acx.io) - Australian Cryptocurrency Exchange

### Requerimientos

* Linux / Mac OSX
* Ruby 2.1.0
* Rails 4.0+
* Git 1.7.10+
* Redis 2.0+
* MySQL
* RabbitMQ

** Mas detalles estan en el [doc](doc).

### Empezando

#### Ingles

* [Setup on Mac OS X](doc/setup-local-osx.md)
* [Setup on Ubuntu](doc/setup-local-ubuntu.md)
* [Deploy production server](doc/deploy-production-server.md)

#### Español
**En construcción**

### API
Aquí hay algunos clientes API o accesorios

* [peatio-client-ruby](https://github.com/peatio/peatio-client-ruby) is the official ruby client of both HTTP/Websocket API.
* [peatio-client-python by JohnnyZhao](https://github.com/JohnnyZhao/peatio-client-python) is a python client written by JohnnyZhao.
* [peatio-client-python by czheo](https://github.com/JohnnyZhao/peatio-client-python) is a python wrapper similar to peatio-client-ruby written by czheo.
* [peatioJavaClient](https://github.com/classic1999/peatioJavaClient.git) is a java client written by classic1999.
* [yunbi-client-php](https://github.com/panlilu/yunbi-client-php) is a php client written by panlilu.

### Custom style

El front-end de Peatio esta basado en la versión 3.0 de Bootstrap y Sass, y usted puede modificar la exchange a su propio estilo que tenga en mente.

* las variables bootstrap por default estan en `vars/_bootstrap.css.scss`
* Las variables de Peatio configuradas estan en `vars/_basic.css.scss`
* sus variables personalizadas en `vars/_custom.css.scss`
* sus variables para estilo css en `layouts/_custom.css.scss`
* Añadir o cambiar el estilo de las características en `features / _xyz.css.scss`

`vars/_custom.css.scss` can overwrite `vars/_basic.css.scss` defined variables

`layout/_custom.css.scss` can overwrite

`layout/_basic.css.scss` and `layoputs/_header.css.scss` style

### Involucrate

¿Quieres reportar un error, solicitar una función, contribuir o traducir Peatio?

* Entra a [issues Peatio Oficial](https://github.com/peatio/peatio/issues) para comentar, proponer o reportar bugs en ingles
* Entra a [issues en este Fork en español](https://github.com/ShadowMyst/peatio/issues) para comentar, proponer o reportar bugs en español
* Clona este repositorio, haz cambios que creas sean necesarios y haz un pull-requests.
* Necesitas algo que decir directamente, puedes enviarme un correo a [theshadowmyst@gmail.com](mailto:theshadowmyst@gmail.com) para el soporte en español o directamente a la comunidad de Peatio al correo [community@peatio.com](mailto:community@peatio.com).
### Licencia.

Peatio is released under the terms of the MIT license. See [http://peatio.mit-license.org](http://peatio.mit-license.org) for more information.

### Donar

**También puedes donarme a mi que esta realizando el soporte en español, para de vez en cuando comprarme un cafe**
* Direccion Bitcoin: [1MFVGu75SP7CvQM7VZCbNeznfxKh2sPUCT](https://blockchain.info/address/1MFVGu75SP7CvQM7VZCbNeznfxKh2sPUCT)

### ¿Qué es Peatio?
[Peatio](http://en.wikipedia.org/wiki/Pixiu) (Chinese: 貔貅) is a Chinese mythical hybrid creature considered to be a very powerful protector to practitioners of Feng Shui.

**[This illustration copyright for Peatio Team]**

![logo](public/peatio.png)
