###
Sliding menu, only supports a single level, requires CSS to run.
The menu shows based on the visibility of the menuButton
https://github.com/sealink/basic-slidemenu
###
$.fn.slidemenu = (options) ->
  selector = this.selector

  settings = $.extend(
    backLabel: "Back"
    backClasses: "slidemenu-back"
    menuLabel: "Menu"
    menuButtonClasses: "slidemenu-toggle"
    LiClasses: "slidemenu-li"
    titleLinkClasses: 'slidemenu-title'
    maxWidth: "767px"
  , options)


  createStyleHeight = (selector, height) ->
    unless $("style.slidemenu").length
      $("head").append('<style type="text/css" class="slidemenu"></style>')
    style =
      """
      @media screen and (max-width: #{settings.maxWidth}) {
        #{selector} {
          height: #{height}
        }
      }
      """
    $("style.slidemenu").text(style)


  addMarkUp = (element) ->
    menu = $(element)
    menu.addClass("slidemenu slidemenu-hidden")

    # Create menu open down button
    menu.before('<a class="'+settings.menuButtonClasses+'" href="#" id="'+menu.attr("id")+'-menu">'+settings.menuLabel+'</a>')

    # Adding the back link, and title
    $('li:has(ul)', menu).each (i , li_elem) ->
      back_link = $('<li class="'+settings.LiClasses+'"><a href="#" data-clicktype="nav" class="'+settings.backClasses+'">'+settings.backLabel+'</a></li>')

      first_link = $(li_elem).find("> a").first()
      first_link.data("clicktype", "nav") #indicate this link as inactive when menu button is showing

      title_link = $('<li class="'+settings.LiClasses+'"><a href="'+first_link.attr("href")+'" data-clicktype="title" class="'+settings.titleLinkClasses+'">'+first_link.text()+'</a></li>')

      $(li_elem).find("> ul").prepend(title_link)
      $(li_elem).find("> ul").prepend(back_link)

  clickListener = (event, menu_element) ->
    menu = $(menu_element)
    menu_button = $('#'+menu.attr("id")+'-menu')
    # Check that we are using the collapsed menu
    if menu_button.is(":visible")
      menu.find(".slidemenu-clicked").removeClass("slidemenu-clicked")
      href = $(event.currentTarget).attr("href")
      clicktype = $(event.currentTarget).data("clicktype") || ''
      parent = $(event.currentTarget).parent()
      window.list = parent.find("> ul").first()

      if clicktype == "nav"
        if href is "#"
          menu.removeClass("slidemenu-child")
          createStyleHeight("#"+menu.attr("id"), "auto")
        else
          parent.addClass("slidemenu-clicked")
          menu.addClass("slidemenu-child")

          #activate animation
          createStyleHeight("#"+menu.attr("id"), menu.height()+"px")
          #set height, without having to clear on resize
          createStyleHeight("#"+menu.attr("id"), list.outerHeight()+"px")

        event.preventDefault()
        event.stopPropagation()
      else
        #when not navigating through the sliding menu, activate the link and shrink the menu
        menu.addClass("slidemenu-hidden")
        menu.removeClass("slidemenu-child")
        menu_button.removeClass("slidemenu-showing")
        if event.type is "touchend"
          #iPhone fix, also speeds up menu activation
          window.location = href

    #When there is no href, always do nothing
    if href is "#"
      event.preventDefault()


  addListeners = (element) ->
    menu = $(element)
    #Show and hide the menu
    menu_button = $('#'+menu.attr("id")+'-menu')
    menu_button.on "click", () ->
      menu.toggleClass("slidemenu-hidden")
      menu_button.toggleClass("slidemenu-showing")

    #For any links touched (not by accidental scrolling)
    menu.on 'touchstart', 'a', (event)->
      $(event.currentTarget).on 'touchend', (event)->
        clickListener(event, element) #Pass the event on
        $(event.currentTarget).unbind('touchend')
      $(event.currentTarget).on 'touchmove', (event)->
        $(event.currentTarget).unbind('touchend')
        $(event.currentTarget).unbind('touchmove')

    #For any links clicked in the menu
    menu.on "click", 'a', (event) ->
      clickListener(event, element)



  return this.each (i, element) ->

    return  if $(element).hasClass("slidemenu") #Already applied, exit

    addMarkUp(element)
    addListeners(element)

    this
