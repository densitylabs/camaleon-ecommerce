$ ->
  form = $('#form-post')
  variation_id = 1
  product_variations = form.find('#product_variations')
  form.find('.content-frame-body > .c-field-group:last').after(product_variations.removeClass('hidden'))
  SERVICE_PRODUCT = "service_product"
  
  # this variables is defined in _variations.html.erb
  is_service = IS_SERVICE
  product_type = PRODUCT_TYPE

  # photo uploader
  product_variations.on('click', '.product_variation_photo_link', ->
    $input = $(this).prev()
    $.fn.upload_filemanager({
      formats: "image",
      dimension: $input.attr("data-dimension") || '',
      versions: $input.attr("data-versions") || '',
      thumb_size: $input.attr("data-thumb_size") || '',
      selected: (file, response) ->
        $input.val(file.url);
    })
    return false
  )

  cache_variation = product_variations.find('.blank_product_variation').remove().clone().removeClass('hidden')
  cache_values = cache_variation.find('.sortable_values > li:first').remove().clone()

  #change product_type
  form.on('change', '.c-field-group .item-custom-field[data-field-key="ecommerce_product_type"] select', ->
    selected = $(this).val()
    if selected == SERVICE_PRODUCT
      is_service = true
      product_type = selected
    else
      is_service = false
      product_type = selected
    check_product_type()
  )

  # add new variation
  product_variations.find('.add_new_variation').click ->
    clone = cache_variation.clone().attr('data-id', 'new_'+variation_id+=1)
    product_variations.children('.variations_sortable').append(clone)
    clone.trigger('fill_variation_id')
    if is_service
      fields_not_required = clone.find('.fn-not-service-product-required')
      clone.find('.fn-product-variation-field').attr('value', SERVICE_PRODUCT)
      for p_field in  fields_not_required
        $(p_field).hide().find('.required').addClass('e_skip_required').removeClass('required')
    check_variation_status()
    return false

  # add new variation value
  product_variations.on('click', '.add_new_value', ->
    clone = cache_values.clone()
    key = $(this).closest('.product_variation').attr('data-id')
    clone.find('input, select').each(->
      $(this).attr('name', $(this).attr('name').replace('[]', '['+key+']')).removeAttr('id')
    )
    $(this).closest('.variation_attributes').find('.sortable_values').append(clone)
    clone.find('.product_attribute_select').trigger('change')
    return false
  )

  # change attribute
  product_variations.on('change', '.product_attribute_select', ->
    v = $(this).val()
    sel = $(this).closest('.row').find('.product_attribute_vals_select').html('')
    for attr in PRODUCT_ATTRIBUTES
      if `attr.id == v`
        for value in attr.translated_values
          sel.append('<option value="'+value.id+'">'+value.label.replace(/</g, '&lt;')+'</option>')
  )

  product_variations.on('fill_variation_id', '.product_variation', ->
    key = $(this).attr('data-id')
    $(this).find('input, select').each(->
      $(this).attr('name', $(this).attr('name').replace('[]', '['+key+']')).removeAttr('id')
    )
    $(this).find('.sortable_values').sortable({handle: '.val_sorter'})
  )

  # sortables
  product_variations.find('.sortable_values').sortable({handle: '.val_sorter'})
  product_variations.find('.variations_sortable').sortable({handle: '.variation_sorter', update: ()->
    $(this).children().each((index)->
      $(this).find('.product_variation_position').val(index);
    )
  })

  # delete actions
  product_variations.on('click', '.val_del', ->
    $(this).closest('li').fadeOut('slow', ->
      $(this).remove()
    )
    return false
  )
  product_variations.on('click', '.var_del', ->
    unless confirm(product_variations.attr('data-confirm-msg'))
      return false
    $(this).closest('.product_variation').fadeOut('slow', ->
      $(this).remove()
      check_variation_status()
    )
    return false
  )

  check_product_type  = ->
    fields = ['ecommerce_weight', 'ecommerce_qty']
    if is_service  # is a service product
      if product_variations.find('.product_variation').length > 0
        # check if exists variations 
        for p_variation in product_variations.find('.product_variation')
          fields_not_required = $(p_variation).find('.fn-not-service-product-required')
          $(p_variation).find('.fn-product-variation-field').attr('value',product_type)
          for p_field in  fields_not_required
            $(p_field).hide().find('.required').addClass('e_skip_required').removeClass('required')
      else
        for key in fields
          p_field = form.find('.c-field-group .item-custom-field[data-field-key="'+key+'"]')
          p_field.hide().find('.required').addClass('e_skip_required').removeClass('required')
      
    else
      # check variations
      if product_variations.find('.product_variation').length > 0
        for p_variation in product_variations.find('.product_variation')
          fields_not_required = $(p_variation).find('.fn-not-service-product-required')
          $(p_variation).find('.fn-product-variation-field').attr('value',product_type)
          for p_field in  fields_not_required
            $(p_field).show().find('.e_skip_required').removeClass('e_skip_required').addClass('required')   
      else
        for key in fields
          p_field = form.find('.c-field-group .item-custom-field[data-field-key="'+key+'"]')
          p_field.show().find('.e_skip_required').removeClass('e_skip_required').addClass('required')
  check_product_type()


  # check the variation status and disable or enable some custom fields
  check_variation_status = ->
    if is_service
      fields = ['ecommerce_sku', 'ecommerce_price', 'ecommerce_stock', 'ecommerce_photos']
    else
      fields = ['ecommerce_sku', 'ecommerce_price', 'ecommerce_weight', 'ecommerce_stock', 'ecommerce_qty', 'ecommerce_photos']

    if product_variations.find('.product_variation').length > 0 # is a variation product
      fields.push('ecommerce_stock', 'ecommerce_qty')
      for key in fields
        p_field = form.find('.c-field-group .item-custom-field[data-field-key="'+key+'"]')
        p_field.hide().find('.required').addClass('e_skip_required').removeClass('required')
    else
      for key in fields
        p_field = form.find('.c-field-group .item-custom-field[data-field-key="'+key+'"]')
        p_field.show().find('.e_skip_required').removeClass('e_skip_required').addClass('required')
  check_variation_status()
