% for k,v in store.getkv('/'):
${store.to_env(k).lower().replace("_", "-")}=${v}
% endfor
