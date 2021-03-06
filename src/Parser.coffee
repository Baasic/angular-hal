do (ng=angular, mod=angular.module('HALParser', [])) ->

  removeNamespace = (name, ns) ->
    ns = if ns then ns + ':' else ''
    if name.substr(0,ns.length) is ns then name.substr(ns.length) else name

  class Parser
    constructor: (@ns) ->
    parse: (hal) =>
      json = angular.copy hal

      {_links, _embedded} = json
      delete json._links
      delete json._embedded

      return new Resource json, _links, _embedded, @ns

    class Resource
      constructor: (data, links, embedded, ns) ->
        ns = if ns then ns else ''
        angular.extend @, data
        resourceLinks = if links then new Links links else {}

        for name, prop of embedded
          @[removeNamespace name, ns] = if ng.isArray prop then new Parser(ns).parse em, ns for em in prop else new Parser(ns).parse prop, ns

        @links = (name = '') ->
          key = if name is 'self' then name else if resourceLinks[name] then name else ns + ':' + name
          if resourceLinks[key] then resourceLinks[key] else resourceLinks

    class Links
      constructor: (links, ns) ->
        if !links?.self
          throw 'Self link is required'
        for name, link of links
          @[name] = if ng.isArray link then new Link lk, ns for lk in link else new Link link, ns

    class Link
      constructor: (link, ns) ->
        if !link?.href
          throw 'href is required for all links'
        {@href, @name, @profile} = link
        @templated = !!link.templated
        @title = link.title or ''

  mod.constant 'HALParser', Parser