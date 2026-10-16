.pragma library

function matchingRule(match, displayText) {
  return {
    match: match,
    displayText: displayText
  };
}

var widgetLayouts = [
  matchingRule("English", "EN"),
  matchingRule("Russian", "RU"),
];

var popupLayouts = [
  matchingRule("English", "English (US)"),
  matchingRule("Russian", "Русский"),
];
