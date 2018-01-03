//= require swagger_ui
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
