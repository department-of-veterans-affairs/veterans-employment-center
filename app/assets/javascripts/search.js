$(document).ready(function(){
	//Mike Asbury added this part
	//This hides/shows the Advanced or Basic portion of the search UI
	var searchType = $('#searchType').val();
    if (searchType != undefined) {
      if(searchType.indexOf("advanced") >= 0){
          $(".advancedSearch").show();
          $(".advancedTag").html("<a href='#'>&#9650; Basic Search</a>");
      } else {
          $(".advancedTag").html("<a href='#'>&#9660; Advanced Search</a>");
          $(".advancedSearch").hide();
      }

      //If the advanced tag is clicked and advanced section is visible, then hide it.  Otherwise, show it.

      $(".advancedTag").click(function(e) {
          e.preventDefault();
          if($(".advancedSearch").is(":visible")){
              $(".advancedSearch").slideUp();
              $(".advancedTag").html("<a href='#'>&#9660; Advanced Search</a>");
              $('#searchType').val("basic");
          } else {
              $(".advancedSearch").slideDown();
              $(".advancedTag").html("<a href='#'>&#9650; Basic Search</a>");
              $('#searchType').val("advanced");
              $('#adv-srch-flds').css({'display': 'block'});
              //mixpanel.track("Advanced Search");
          }

      });

      //End part added by Mike Asbury

      $.ui.autocomplete.prototype._renderItem = function( ul, item){
          /**
          Add syntax highlighting to autocomplete results.

          Inputs:
          :ul:    the autocomplete object to modify
          :item:  the individual item to modify

          Returns:
          Modified item

          **/
          var term = this.term;
          if((term.charAt(0)=='"' && term.charAt(term.length-1) == '"')){
              term = this.term.substr(1,term.length-2);
          }else{
              term = this.term.split(' ').join('|');
          }
          var re = new RegExp("(" + term + ")", "gi") ;
          var t = item.label.replace(re,"<b class='ac-highlight'>$1</b>");
          return $( "<li></li>" )
              .data( "item.autocomplete", item )
              .append( "<a>" + t + "</a>" )
              .appendTo( ul );
      };
      $("#standardSearch input[type=text]").bind("autocompleteselect", function(event, ul) {
          /**
          When an autocomplete suggestion is selected, submit the search form
          if location and title fields have a value in them.

          This applies to the MOC, Location, and Title fields on the
          standardSearch form.

          Inputs:
          :event: The autocompleteselect event
          :ul: The autocomplete object (an unordered list)

          Returns:
          Nothing (but does submit search form if both fields have values)

           **/
          $(this).val(ul.item.value);
          if ($('#moc').length > 0) {
              if ($('#location').val() != "" && $('#q').val() != "" && $('#moc').val() != "") {
                 $("#standardSearch").submit();
              }
          }
          else {
              if ($('#location').val() != "" && $('#q').val() != "") {
                 $("#standardSearch").submit();
              }
          }
      });
      $( ".micrositeLocationField" ).autocomplete({
          /**
          Add autocomplete functionality to the Where search field.

          **/
          source: function( request, response ) {
              $.ajax({
                  url: "http://usa.jobs/ajax/ac/?lookup=location&term="+request.term,
                  dataType: "jsonp",
                  success: function( data ) {
                      //alert(data[1].label);
                      response( $.map( data, function( item ) {
                          return {
                              label: item.location + " - (" + item.jobcount + ")",
                              value: item.location
                          };
                      }));
                  }
              });
          },
          open: function(event, ul) {
              $(".ui-autocomplete li.ui-menu-item:odd").addClass("ui-menu-item-alternate");
          },
          minLength: 2
      });
      $( ".micrositeTitleField" ).autocomplete({
          /**
          Add autocomplete functionality to the What search field.

          **/
          source: function( request, response ) {
              $.ajax({
                  url: "http://usa.jobs/ajax/ac/?lookup=title&term="+request.term,
                  dataType: "jsonp",
                  success: function( data ) {
                      response( $.map( data, function( item ) {
                          return {
                              // Removing numbers to avoid confusion for now
                              label: item.title,
                              value: item.title
                          };
                      }));
                  }
              });
          },
          open: function(event, ul) {
              $(".ui-autocomplete li.ui-menu-item:odd").addClass("ui-menu-item-alternate");
              $(".ui-autocomplete li.ui-menu-item a").removeClass("ui-corner-all");
          },
          minLength: 2
      });
      $( ".micrositeMOCField" ).autocomplete({
          /**
          Add autocomplete functionality to the MOC/MOS search field.

          **/
          source: function( request, response ) {
              $.ajax({
                  url: "http://usa.jobs/ajax/mac/?lookup=moc&term="+request.term,
                  dataType: "jsonp",
                  success: function( data ) {
                      response( $.map( data, function( item ) {
                          return {
                              label: item.label,
                              value: item.value,
                          };
                      }));
                  }
              });
          },
          select: function( event, ui ) {
              $( "<div/>" ).text(ui.item.label).prependTo( "#moc.id" );
          },
          open: function(event, ul) {
              $(".ui-autocomplete li.ui-menu-item:odd").addClass("ui-menu-item-alternate");
          },
          minLength: 2
      });
    }
});

function resetForm(elts) {
  var fields = ["kw", "zc", "moc", "rs", "re", "zc1", "rd1", "onet", "ind", "cname", "tm"];
  $.each(fields, function(i, field) {
    $("#" + field).val("")
  });
}

/*------------------------------------------------*
 * Limit the characters that may be entered in a text field
 * Common options: alphanumeric, alphabetic or numeric
 * Kevin Sheedy, 2012
 * http://github.com/KevinSheedy/jquery.alphanum
------------------------------------------------*/
(function($){$.fn.alphanum=function(settings){var combinedSettings=getCombinedSettingsAlphaNum(settings);var $collection=this;setupEventHandlers($collection,trimAlphaNum,combinedSettings);return this};$.fn.alpha=function(settings){var defaultAlphaSettings=getCombinedSettingsAlphaNum("alpha");var combinedSettings=getCombinedSettingsAlphaNum(settings,defaultAlphaSettings);var $collection=this;setupEventHandlers($collection,trimAlphaNum,combinedSettings);return this};$.fn.numeric=function(settings){var combinedSettings=getCombinedSettingsNum(settings);var $collection=this;setupEventHandlers($collection,trimNum,combinedSettings);$collection.blur(function(){numericField_Blur(this,settings)});return this};var DEFAULT_SETTINGS_ALPHANUM={allow:"",disallow:"",allowSpace:true,allowNumeric:true,allowUpper:true,allowLower:true,allowCaseless:true,allowLatin:true,allowOtherCharSets:true,forceUpper:false,forceLower:false,maxLength:NaN};var DEFAULT_SETTINGS_NUM={allowPlus:false,allowMinus:true,allowThouSep:true,allowDecSep:true,allowLeadingSpaces:false,maxDigits:NaN,maxDecimalPlaces:NaN,maxPreDecimalPlaces:NaN,max:NaN,min:NaN};var CONVENIENCE_SETTINGS_ALPHANUM={alpha:{allowNumeric:false},upper:{allowNumeric:false,allowUpper:true,allowLower:false,allowCaseless:true},lower:{allowNumeric:false,allowUpper:false,allowLower:true,allowCaseless:true}};var CONVENIENCE_SETTINGS_NUMERIC={integer:{allowPlus:false,allowMinus:true,allowThouSep:false,allowDecSep:false},positiveInteger:{allowPlus:false,allowMinus:false,allowThouSep:false,allowDecSep:false}};var BLACKLIST=getBlacklistAscii()+getBlacklistNonAscii();var THOU_SEP=",";var DEC_SEP=".";var DIGITS=getDigitsMap();var LATIN_CHARS=getLatinCharsSet();function getBlacklistAscii(){var blacklist="!@#$%^&*()+=[]\\';,/{}|\":<>?~`.-_";blacklist+=" ";return blacklist}function getBlacklistNonAscii(){var blacklist="\u00ac\u20ac\u00a3\u00a6";return blacklist}function setupEventHandlers($textboxes,trimFunction,settings){$textboxes.each(function(){var $textbox=$(this);$textbox.bind("keyup change paste",function(e){var pastedText="";if(e.originalEvent&&(e.originalEvent.clipboardData&&e.originalEvent.clipboardData.getData)){pastedText=e.originalEvent.clipboardData.getData("text/plain")}setTimeout(function(){trimTextbox($textbox,trimFunction,settings,pastedText)},0)});$textbox.bind("keypress",function(e){var charCode=!e.charCode?e.which:e.charCode;if(isControlKey(charCode)||(e.ctrlKey||e.metaKey)){return}var newChar=String.fromCharCode(charCode);var selectionObject=$textbox.selection();var start=selectionObject.start;var end=selectionObject.end;var textBeforeKeypress=$textbox.val();var potentialTextAfterKeypress=textBeforeKeypress.substring(0,start)+newChar+textBeforeKeypress.substring(end);var validatedText=trimFunction(potentialTextAfterKeypress,settings);if(validatedText!=potentialTextAfterKeypress){e.preventDefault()}})})}function numericField_Blur(inputBox,settings){var fieldValueNumeric=parseFloat($(inputBox).val());var $inputBox=$(inputBox);if(isNaN(fieldValueNumeric)){$inputBox.val("");return}if(isNumeric(settings.min)&&fieldValueNumeric<settings.min){$inputBox.val("")}if(isNumeric(settings.max)&&fieldValueNumeric>settings.max){$inputBox.val("")}}function isNumeric(value){return !isNaN(value)}function isControlKey(charCode){if(charCode>=32){return false}if(charCode==10){return false}if(charCode==13){return false}return true}function trimTextbox($textBox,trimFunction,settings,pastedText){var inputString=$textBox.val();if(inputString==""&&pastedText.length>0){inputString=pastedText}var outputString=trimFunction(inputString,settings);if(inputString==outputString){return}var caretPos=$textBox.alphanum_caret();$textBox.val(outputString);if(inputString.length==outputString.length+1){$textBox.alphanum_caret(caretPos-1)}else{$textBox.alphanum_caret(caretPos)}}function getCombinedSettingsAlphaNum(settings,defaultSettings){if(typeof defaultSettings=="undefined"){defaultSettings=DEFAULT_SETTINGS_ALPHANUM}var userSettings,combinedSettings={};if(typeof settings==="string"){userSettings=CONVENIENCE_SETTINGS_ALPHANUM[settings]}else{if(typeof settings=="undefined"){userSettings={}}else{userSettings=settings}}$.extend(combinedSettings,defaultSettings,userSettings);if(typeof combinedSettings.blacklist=="undefined"){combinedSettings.blacklistSet=getBlacklistSet(combinedSettings.allow,combinedSettings.disallow)}return combinedSettings}function getCombinedSettingsNum(settings){var userSettings,combinedSettings={};if(typeof settings==="string"){userSettings=CONVENIENCE_SETTINGS_NUMERIC[settings]}else{if(typeof settings=="undefined"){userSettings={}}else{userSettings=settings}}$.extend(combinedSettings,DEFAULT_SETTINGS_NUM,userSettings);return combinedSettings}function alphanum_allowChar(validatedStringFragment,Char,settings){if(settings.maxLength&&validatedStringFragment.length>=settings.maxLength){return false}if(settings.allow.indexOf(Char)>=0){return true}if(settings.allowSpace&&Char==" "){return true}if(settings.blacklistSet.contains(Char)){return false}if(!settings.allowNumeric&&DIGITS[Char]){return false}if(!settings.allowUpper&&isUpper(Char)){return false}if(!settings.allowLower&&isLower(Char)){return false}if(!settings.allowCaseless&&isCaseless(Char)){return false}if(!settings.allowLatin&&LATIN_CHARS.contains(Char)){return false}if(!settings.allowOtherCharSets){if(DIGITS[Char]||LATIN_CHARS.contains(Char)){return true}else{return false}}return true}function numeric_allowChar(validatedStringFragment,Char,settings){if(DIGITS[Char]){if(isMaxDigitsReached(validatedStringFragment,settings)){return false}if(isMaxPreDecimalsReached(validatedStringFragment,settings)){return false}if(isMaxDecimalsReached(validatedStringFragment,settings)){return false}if(isGreaterThanMax(validatedStringFragment+Char,settings)){return false}if(isLessThanMin(validatedStringFragment+Char,settings)){return false}return true}if(settings.allowPlus&&(Char=="+"&&validatedStringFragment=="")){return true}if(settings.allowMinus&&(Char=="-"&&validatedStringFragment=="")){return true}if(Char==THOU_SEP&&(settings.allowThouSep&&allowThouSep(validatedStringFragment,Char))){return true}if(Char==DEC_SEP){if(validatedStringFragment.indexOf(DEC_SEP)>=0){return false}if(settings.allowDecSep){return true}}return false}function countDigits(string){string=string+"";return string.replace(/[^0-9]/g,"").length}function isMaxDigitsReached(string,settings){var maxDigits=settings.maxDigits;if(maxDigits==""||isNaN(maxDigits)){return false}var numDigits=countDigits(string);if(numDigits>=maxDigits){return true}return false}function isMaxDecimalsReached(string,settings){var maxDecimalPlaces=settings.maxDecimalPlaces;if(maxDecimalPlaces==""||isNaN(maxDecimalPlaces)){return false}var indexOfDecimalPoint=string.indexOf(DEC_SEP);if(indexOfDecimalPoint==-1){return false}var decimalSubstring=string.substring(indexOfDecimalPoint);var numDecimals=countDigits(decimalSubstring);if(numDecimals>=maxDecimalPlaces){return true}return false}function isMaxPreDecimalsReached(string,settings){var maxPreDecimalPlaces=settings.maxPreDecimalPlaces;if(maxPreDecimalPlaces==""||isNaN(maxPreDecimalPlaces)){return false}var indexOfDecimalPoint=string.indexOf(DEC_SEP);if(indexOfDecimalPoint>=0){return false}var numPreDecimalDigits=countDigits(string);if(numPreDecimalDigits>=maxPreDecimalPlaces){return true}return false}function isGreaterThanMax(numericString,settings){if(!settings.max||settings.max<0){return false}var outputNumber=parseFloat(numericString);if(outputNumber>settings.max){return true}return false}function isLessThanMin(numericString,settings){if(!settings.min||settings.min>0){return false}var outputNumber=parseFloat(numericString);if(outputNumber<settings.min){return true}return false}function trimAlphaNum(inputString,settings){if(typeof inputString!="string"){return inputString}var inChars=inputString.split("");var outChars=[];var i=0;var Char;for(i=0;i<inChars.length;i++){Char=inChars[i];var validatedStringFragment=outChars.join("");if(alphanum_allowChar(validatedStringFragment,Char,settings)){outChars.push(Char)}}var outputString=outChars.join("");if(settings.forceLower){outputString=outputString.toLowerCase()}else{if(settings.forceUpper){outputString=outputString.toUpperCase()}}return outputString}function trimNum(inputString,settings){if(typeof inputString!="string"){return inputString}var inChars=inputString.split("");var outChars=[];var i=0;var Char;for(i=0;i<inChars.length;i++){Char=inChars[i];var validatedStringFragment=outChars.join("");if(numeric_allowChar(validatedStringFragment,Char,settings)){outChars.push(Char)}}return outChars.join("")}function removeUpperCase(inputString){var charArray=inputString.split("");var i=0;var outputArray=[];var Char;for(i=0;i<charArray.length;i++){Char=charArray[i]}}function removeLowerCase(inputString){}function isUpper(Char){var upper=Char.toUpperCase();var lower=Char.toLowerCase();if(Char==upper&&upper!=lower){return true}else{return false}}function isLower(Char){var upper=Char.toUpperCase();var lower=Char.toLowerCase();if(Char==lower&&upper!=lower){return true}else{return false}}function isCaseless(Char){if(Char.toUpperCase()==Char.toLowerCase()){return true}else{return false}}function getBlacklistSet(allow,disallow){var setOfBadChars=new Set(BLACKLIST+disallow);var setOfGoodChars=new Set(allow);var blacklistSet=setOfBadChars.subtract(setOfGoodChars);return blacklistSet}function getDigitsMap(){var array="0123456789".split("");var map={};var i=0;var digit;for(i=0;i<array.length;i++){digit=array[i];map[digit]=true}return map}function getLatinCharsSet(){var lower="abcdefghijklmnopqrstuvwxyz";var upper=lower.toUpperCase();var azAZ=new Set(lower+upper);return azAZ}function allowThouSep(currentString,Char){if(currentString.length==0){return false}var posOfDecSep=currentString.indexOf(DEC_SEP);if(posOfDecSep>=0){return false}var posOfFirstThouSep=currentString.indexOf(THOU_SEP);if(posOfFirstThouSep<0){return true}var posOfLastThouSep=currentString.lastIndexOf(THOU_SEP);var charsSinceLastThouSep=currentString.length-posOfLastThouSep-1;if(charsSinceLastThouSep<3){return false}var digitsSinceFirstThouSep=countDigits(currentString.substring(posOfFirstThouSep));if(digitsSinceFirstThouSep%3>0){return false}return true}function Set(elems){if(typeof elems=="string"){this.map=stringToMap(elems)}else{this.map={}}}Set.prototype.add=function(set){var newSet=this.clone();for(var key in set.map){newSet.map[key]=true}return newSet};Set.prototype.subtract=function(set){var newSet=this.clone();for(var key in set.map){delete newSet.map[key]}return newSet};Set.prototype.contains=function(key){if(this.map[key]){return true}else{return false}};Set.prototype.clone=function(){var newSet=new Set;for(var key in this.map){newSet.map[key]=true}return newSet};function stringToMap(string){var map={};var array=string.split("");var i=0;var Char;for(i=0;i<array.length;i++){Char=array[i];map[Char]=true}return map}$.fn.alphanum.backdoorAlphaNum=function(inputString,settings){var combinedSettings=getCombinedSettingsAlphaNum(settings);return trimAlphaNum(inputString,combinedSettings)};$.fn.alphanum.backdoorNumeric=function(inputString,settings){var combinedSettings=getCombinedSettingsNum(settings);return trimNum(inputString,combinedSettings)};$.fn.alphanum.setNumericSeparators=function(settings){if(settings.thousandsSeparator.length!=1){return}if(settings.decimalSeparator.length!=1){return}THOU_SEP=settings.thousandsSeparator;DEC_SEP=settings.decimalSeparator}})(jQuery);(function($){function caretTo(el,index){if(el.createTextRange){var range=el.createTextRange();range.move("character",index);range.select()}else{if(el.selectionStart!=null){el.focus();el.setSelectionRange(index,index)}}}function caretPos(el){if("selection" in document){var range=el.createTextRange();try{range.setEndPoint("EndToStart",document.selection.createRange())}catch(e){return 0}return range.text.length}else{if(el.selectionStart!=null){return el.selectionStart}}}$.fn.alphanum_caret=function(index,offset){if(typeof index==="undefined"){return caretPos(this.get(0))}return this.queue(function(next){if(isNaN(index)){var i=$(this).val().indexOf(index);if(offset===true){i+=index.length}else{if(typeof offset!=="undefined"){i+=offset}}caretTo(this,i)}else{caretTo(this,index)}next()})}})(jQuery);
