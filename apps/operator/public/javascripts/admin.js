function GetIdFromClassName(objElement, base) {
  var className = HasClassName(objElement, base);
  var nameArray = className.split("_");
  return nameArray[1];
}
function HasClassName(objElement, base) {
  // if there is a class
  if ( objElement.className ) {
    // the classes are just a space separated list, so first get the list
    var arrList = objElement.className.split(' ');

    // find all instances and remove them
    for ( var i = 0; i < arrList.length; i++ ) {
      // if class found
      if ( arrList[i].substr(0,3) == base ) {
        return arrList[i];
      }
    }
  }
  // if we got here then the class name is not there
  return false;
}

// Identity Form
$('.hidden').hide();
$('p#identity').click(function() {
  $('#identity_form').toggle();
  $("input#identity").select();
});
$('#identity_cancel').click(function() {
  $('#identity_form').toggle(); 
  return false;
});



// CHG Item Click - causes edit
$('a.chg_edit').click(function() {
  var form      = $('form#chg_form');
  var textField = $('input#chg');
  var submit    = $('input#chg_submit');

  var parentDiv = this.parentNode;
  var chg_id    = GetIdFromClassName(parentDiv, "chg");

  // Hide the existing form button
  $('p#chg').hide();

  // Set the action to update
  form.get(0).setAttribute('action', '/call_handler_group/'+chg_id);
  submit.val('Update');

  // Set the text field value and show it
  textField.val(this.innerHTML);
  form.show();
  textField.select();
  
  return false;
});

// #chg_did Did Item Click
$('a.did_edit').click(function() {
  var form                 = $('form#did_form');
  var priTextField         = $('input#did__pri_number');
  var numberTextField      = $('input#did__number');
  var descriptionTextField = $('input#did__description');
  var submit               = $('input#did__submit');
  
  var parentDiv = this.parentNode;
  var did_id    = GetIdFromClassName(parentDiv, "did");
  
  // Hide the existing from button
  $('p#did').hide();
  
  // Set the action to update
  form.get(0).setAttribute('action', '/did/'+did_id);
  submit.val('Update');

  priTextField.val('fred');
  numberTextField.val('foo');
  descriptionTextField.val('bar');
  // Set Radio
  form.show();
  priTextField.select();

  return false;
});

// Did Form
$('p#did').click(function() {
  $('#did_form').toggle();
  $('p#did').toggle();
  $("input#did").select();
  return false;
});
$('#did_cancel').click(function() {
  $('#did_form').toggle(); 
  $('p#did').toggle();
  return false;
});

// Did Hover
$('.item').mouseover(function() {
  $('.item_control span', this).show();
});
$('.item').mouseout(function() {
  $('.item_control span', this).hide();
});

// Call Handler Group Form Add button clicked
$('p#chg').click(function() {
  var form      = $('form#chg_form');
  var textField = $('input#chg');
  var submit    = $('input#chg_submit');

  $('#chg_form').toggle();
  $('p#chg').toggle();

  textField.val('');
  textField.select();

  // Set the action to Add
  form.get(0).setAttribute('action', '/call_handler_group');
  submit.val('Add');

  return false;
});

$('#chg_cancel').click(function() {
  $('#chg_form').toggle(); 
  $('p#chg').toggle();
  return false;
});

// Ring Set Form Add button clicked
$('p#ring_set').click(function() {
  var form      = $('form#ring_set__form');
  var textField = $('input#ring_set__name');
  var submit    = $('input#ring_set__submit');

  $('#ring_set__form').toggle();
  $('p#ring_set').toggle();

  textField.val('');
  textField.select();

  // Set the action to Add
  form.get(0).setAttribute('action', '/ring_set');
  submit.val('Add');

  return false;
});
$('a#ring_set__cancel').click(function() {
  $('#ring_set__form').hide();
  $('p#ring_set').show();
  return false;
});


// Number Form Add button clicked
$('p#numberButton').click(function() {
  var form        = $('form#number__form');
  var numberField = $('input#number');
  var submit      = $('input#number__submit');

  $('#number__form').toggle();
  $('p#number').toggle();

  numberField.val('');
  numberField.select();

  // Set the action to Add
  form.get(0).setAttribute('action', '/number');
  submit.val('Add');

  return false;
});
$('a#number__cancel').click(function() {
  $('#number__form').hide();
  $('p#numberButton').show();
  return false;
});
