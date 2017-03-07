function preventDefaultIfPossible(e) {
  try {
    e.preventDefault();
  } catch(ex) { }
}

function preventDefaultWithHash(e, self) {
  preventDefaultIfPossible(e);
  var link = $(self);
  if (link && link.length > 0)
    window.location.hash = link.attr('href');
}