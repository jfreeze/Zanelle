internal {
  log_internal_call

  #zanelle :debug => true

  case @extension.to_s
    when '515'
      #execute 'Set', 'CALLERID(all)=Fred<999>' # Works
      #set_variable('CALLERID(all)', 'fred <999>')
      dial_inside '515'
  end

  case @extension.to_s
    when /^\d{7}$/
      dial_out "512#{@extension}"
    when /^\d{3,11}$/
      dial_out @extension
  end
}

inbound {
  case @extension.to_s
    when '6825'
      dial_inside '515'
  end
  #zanelle :debug => true
}

