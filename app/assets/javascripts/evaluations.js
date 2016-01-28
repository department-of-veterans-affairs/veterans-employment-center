var Application = {
  // TODO: this isn't easily testable
  init: function() {
    var _this = this;

    var prefix = 'evaluation_data_diabetes_evaluation_data';
    var prefixName = function(fieldName) {
      return prefix + '[' + fieldName + ']';
    }

    this.displayConditionalOn(prefixName);
    this.disableConditionalOn(prefixName);

    // For each field with a data mask, apply it
    $("input[data-mask]").each(function() {
      var item = $(this)
      item.mask(item.attr("data-mask"));
    })
  },

  identity: function(x) {return x},

  copyFields: function(fromFields, toFields) {
    if (fromFields.length !== toFields.length) {
      throw 'from and to fields must match in length';
    }
    var len = fromFields.length;
    for (var i = 0; i < len; i++) {
      var val = $(fromFields[i]).val();
      $(toFields[i]).val(val);
    }
  },

  // TODO: could (unlikely) leak
  _savedFieldsCache: {},

  saveFields: function(fields) {
    var save = {};
    for (var i = 0; i < fields.length; i++) {
      save[fields[i]] = $(fields[i]).val();
    }
    this._savedFieldsCache[fields] = save;
  },

  restoreFields: function(fields) {
    var undefined;
    var save = this._savedFieldsCache[fields];
    if (save === undefined) {
      throw 'no previously saved fields';
    }
    for (var i = 0; i < fields.length; i++) {
      var val = save[fields[i]] || '';
      $(fields[i]).val(val);
    }
  },

  // displayConditionalOn is a simple means for conditionally
  // displaying an element based on user input. Assumes a checkbox
  // or radio button for the conditional field, with stringified
  // boolean values - "true" or "false". `undefined' is treated as
  // false. It takes an optional argument `nameFn' which should be a
  // function that takes the name of the field and returns a string,
  // which will be the input to a jQuery [name] selector.
  displayConditionalOn: function(nameFn) {
    nameFn = nameFn || this.identity;
    // test tests for the truth of the input field. `invert' is an
    // optional boolean that, if true, inverts the sense of the
    // truth test.
    var test = function(input, invert) {
      return function() {
        if (invert) {
          return $(input).val() !== undefined && ($(input).val() !== 'true' || $(input).val() === '1');
        }
        return $(input).val() === 'true' || $(input).val() === '1';
      };
    };
    var toggle = function(test, el) {
      test() ? $(el).show() : $(el).hide();
    };
    $('[data-display-conditional-on]').each(function() {
      // Get the name of the form field this element's display is conditional upon.
      var condField = $(this).data('display-conditional-on');
      var invert = false;
      // A leading '!' inverts the sense of the conditional.
      if (condField.charAt(0) === '!') {
        invert = true;
        condField = condField.slice(1);
      }
      var selector = '[name="' + nameFn(condField) + '"]';
      var testFn = test(selector + ':checked', invert);
      var _this = this;
      // Set initial hidden/shown state.
      toggle(testFn, this);
      $(selector).change(function() {
        toggle(testFn, _this);
      });
    });
  },

  disableConditionalOn: function(nameFn) {
    nameFn = nameFn || this.identity;
    var disablerFields = {}; // map of field to list of fields that are conditional on it
    var _this = this;
    $('[data-disable-conditional-on]').each(function() {
      var baseName = $(this).data('disable-conditional-on');
      var selector = '[name="' + nameFn(baseName) + '"]';
      var conditionalFields = disablerFields[selector] || [];
      conditionalFields.push($(this));
      disablerFields[selector] = conditionalFields;
    });
    for (var field in disablerFields) {
      $(field).change(function() {
        for (var i = 0; i < disablerFields[field].length; i++) {
          var f = disablerFields[field][i];
          var disabled = f.prop('disabled');
          if (!disabled) {
            _this.saveFields(['[name="' + f.attr('name') + '"]']);
            f.val('');
          } else {
            _this.restoreFields(['[name="' + f.attr('name') + '"]']);
          }
          f.prop('disabled', !disabled);
        }
      });
    }
  }
};

$(function() {
  // TODO: only fire when we're on the application controller/view
  Application.init();
});