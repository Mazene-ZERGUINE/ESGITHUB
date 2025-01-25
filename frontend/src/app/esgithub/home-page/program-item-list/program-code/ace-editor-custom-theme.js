import * as ace from 'ace-builds';

ace.define(
  'ace/theme/custom_theme',
  ['require', 'exports', 'module', 'ace/lib/dom'],
  function (require, exports) {
    exports.isDark = true;
    exports.cssClass = 'ace-custom-theme';
    exports.cssText = `
    .ace-custom-theme .ace_gutter {
      background: #5D5D5D;
      color: #E0E0E0;
    }
    .ace-custom-theme .ace_print-margin {
      width: 1px;
      background: #5D5D5D;
    }
    .ace-custom-theme {
      background-color: #5D5D5D;
      color: #E0E0E0;
    }
    .ace-custom-theme .ace_cursor {
      color: #FFFFFF;
    }
    .ace-custom-theme .ace_marker-layer .ace_selection {
      background: #6699CC;
    }
    .ace-custom-theme.ace_multiselect .ace_selection.ace_start {
      box-shadow: 0 0 3px 0px #5D5D5D;
    }
    .ace-custom-theme .ace_marker-layer .ace_step {
      background: rgb(198, 219, 174);
    }
    .ace-custom-theme .ace_marker-layer .ace_bracket {
      margin: -1px 0 0 -1px;
      border: 1px solid #E0E0E0;
    }
    .ace-custom-theme .ace_marker-layer .ace_active-line {
      background: #444444;
    }
    .ace-custom-theme .ace_gutter-active-line {
      background-color: #444444;
    }
    .ace-custom-theme .ace_marker-layer .ace_selected-word {
      border: 1px solid #6699CC;
    }
    .ace-custom-theme .ace_fold {
      background-color: #6699CC;
      border-color: #E0E0E0;
    }
    .ace-custom-theme .ace_keyword {
      color: #CC7832;
    }
    .ace-custom-theme .ace_constant {
      color: #6A8759;
    }
    .ace-custom-theme .ace_support {
      color: #9CDCFE;
    }
    .ace-custom-theme .ace_variable {
      color: #D19A66;
    }
    .ace-custom-theme .ace_string {
      color: #CE9178;
    }
    .ace-custom-theme .ace_comment {
      color: #629755;
    }
    .ace-custom-theme .ace_meta.ace_tag {
      color: #E8BF6A;
    }
    .ace-custom-theme .ace_entity.ace_other.ace_attribute-name {
      color: #E8BF6A;
    }
  `;
    var dom = require('ace/lib/dom');
    dom.importCssString(exports.cssText, exports.cssClass);
  },
);
