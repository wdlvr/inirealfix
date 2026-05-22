function tag = make_tag(label)
%MAKE_TAG Convert a label into a safe filename tag.

tag = lower(label);
tag = regexprep(tag, '[^a-z0-9]+', '_');
tag = regexprep(tag, '_+', '_');
tag = regexprep(tag, '^_|_$', '');
