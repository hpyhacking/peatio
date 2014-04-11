//= require swagger-ui/lib/shred.bundle
//= require swagger-ui/lib/jquery-1.8.0.min
//= require swagger-ui/lib/jquery.slideto.min
//= require swagger-ui/lib/jquery.wiggle.min
//= require swagger-ui/lib/jquery.ba-bbq.min
//= require swagger-ui/lib/handlebars-1.0.0
//= require swagger-ui/lib/underscore-min
//= require swagger-ui/lib/backbone-min
//= require swagger-ui/lib/swagger
//= require swagger-ui/swagger-ui
//= require swagger-ui/lib/highlight.7.3.pack
//= require bootstrap/dropdown

$(function() {

  window.swaggerUi = new SwaggerUi({
    url: "/api/v2/doc/swagger",
    dom_id: "swagger-ui-container",
    supportedSubmitMethods: ['get', 'post', 'put', 'delete'],
    onComplete: function(swaggerApi, swaggerUi){
      log("Loaded SwaggerUI");

      $('pre code').each(function(i, e) {
        hljs.highlightBlock(e)
      });
    },
    onFailure: function(data) {
      log("Unable to Load SwaggerUI");
    },
    docExpansion: "none"
  });

  window.swaggerUi.load();

});
