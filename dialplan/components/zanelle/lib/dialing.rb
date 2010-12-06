ASTERISK = '/opt/depot/asterisk-1.4.24.1/sbin/asterisk'
ASTERISK_ROOT = '/opt/depot/asterisk-1.4.24.1'
Log = Logger.new(STDOUT)
Log.level = Logger::DEBUG


#512-225-0721 thru 0735 
# 225-0735

methods_for :dialplan do

  def log_inbound_call
    Log.debug "\n"+"==> CONTEXT: inbound" 
    log_dump_status
  end

  def log_internal_call
    Log.debug "\n" + "==> Context: internal"
    log_dump_status
  end

  def log_dump_status
    log_data "Office State:  #{get_state 'office'}"
    log_data "Extension:     #{extension}"
    log_data "CallerID:      #{callerid}"
    log_data "Caller Number: #{caller_num}"
    log_data "CallerID Name: #{calleridname}"
    log_data "Channel:       #{channel}"
  end

  def audio_file_play_path(name)
    File.join(ASTERISK_ROOT, 'var', 'lib', 'asterisk', 'recordings', name)
  end

  def audio_file_record_path(name, format='.wav')
    format = '.'+format unless '.' == format[0..0]
    audio_file_play_path(name) + format
  end

  def ivr_name(s)
    "ivr-recording-#{s}"
  end

  def get_state(key='office')
    `#{ASTERISK} -rx 'database get #{key} state '`.strip.sub(/^Value:\s+/,'')
  end

  def set_state(key, value)
    `#{ASTERISK} -rx 'database put #{key} state #{value}'`.strip.sub(/^Value:\s+/,'')
  end

  def record_message_file(ext=@extension)
      sleep 1

      num  = "#{extension}"[1..-1]
      name = ivr_name(num)

      rfile = audio_file_record_path(name)
      log_action "Recording #{rfile}"
      record rfile, 1, 0

      sleep 1

      pfile = audio_file_play_path(name)
      log_action "Playing #{pfile}"
      play(pfile)
  end

  def play_message_file(num=nil)
      sleep 1

      num  = "#{@extension}"[1..-1] if num.nil?
      name = ivr_name(num)
      file = audio_file_play_path(name)

      log_action "Playing file #{file}"
      play(file)
  end

  def dial_out(ext, options="TK")
#    sip = "SIP/Xva16QZC24:vjh37zyh74@voicepulse-primary/1512#{ext}"
#    sip = "SIP/501@Xva16QZC24:vjh37zyh74@voicepulse-primary/1512#{ext}"
#    sip = "SIP/voicepulse-primary/1512#{ext}"
    dahdi = "DAHDI/g1/#{ext}"
    log_action "Dialing internal to external"
    log_data "#{dahdi}"
    dial dahdi, :options => options
    handle_unsuccessful_call
    end_call
  end

  def set_ring(sound)
    ring =
    case sound
      when :internal then  ["SIPAddHeader", '"Alert-Info: Internal"']
      when :pa then ["SIPAddHeader", '"Alert-Info: Ring Answer"']
    end
    log_action ring.join(", ")
    execute *ring
  end

  def dial_inside(ext=@extension, duration=100.seconds, options="tkr")
    log_action "Dialing to internal"

    sip        = [ext].flatten.map { |s| "SIP/#{s}" }.join("&")
    log_data   sip

    log_data "Dialing ..."
    #dial sip, :for => duration, :options => options#, :caller_id => caller_num
    dial sip, :for => duration, :options => options, :name => 'fred', :caller_id => '999'

    handle_internal_unsuccessful_call
    end_call
  end

  def dial_ring_set(n, re=/.*/, options="tkr")
    log_action "Dialing ring_set #{n} to internal"
   
    rs = ring_set(n)

p rs[:numbers]
    dn = rs[:numbers].select { |n| n =~ re }
    sip        = dn.map { |s| "SIP/#{s}" }.join("&")
    log_data   sip

    log_data "Dialing ..."
    dial sip, :for => rs[:duration], :options => options, :caller_id => caller_num

    handle_unsuccessful_call
    end_call
  end


  def dial_inside_pa(ext, duration=15.seconds, options="tr")
    log_action "Dialing internal to internal on PA"

    sip        = [ext].flatten.map { |s| "SIP/#{s}" }.join("&")
    log_data   sip

    set_ring :pa

    log_data "Dialing ..."
    dial sip, :for => duration, :options => options, :caller_id => caller_num

    handle_unsuccessful_call
    end_call
  end

  def caller_num
    #SIP/501-0964e080
    num =
    if /sip/i =~ channel
      (/^[^\/]+\/([^-]+)/.match(channel)[1]).to_i
    else
      callerid
    end
    # ensure return value is a number
    /[^0-9]/ =~ "#{num}" ? 0 : num 
  end

  def log_action action
    Log.debug "    - #{action}"
  end
  def log_data data
    Log.debug "      #{data}"
  end

  def end_call
    Log.debug "--- call ended ---"
  end

  def handle_internal_unsuccessful_call
    log_data "Dial Result: #{last_dial_status}"
    busy_to_voicemail
    congested
  end

  def handle_unsuccessful_call
    log_data "Dial Result: #{last_dial_status}"
    busy
    congested
  end

  def busy
    if last_dial_status == :busy
      log_data "Call is Busy"
      execute('busy') 
    end
  end

  def busy_to_voicemail
    log_data "would go to vm"
    if last_dial_status == :busy
      log_data "Call is Busy"
      # What does @extension look like if it is an array?
      #execute('busy') 
      voicemail("#{@extension}@internal")
    end
  end

  def congested
    if last_dial_status == :congested
      log_data "Call is Congested"
      execute('Congestion') 
    end
  end

end
