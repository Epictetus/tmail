$:.unshift File.dirname(__FILE__)
require 'test_helper'

class TestQuote < Test::Unit::TestCase
  def test_unquote_quoted_printable
    a ="=?ISO-8859-1?Q?[166417]_Bekr=E6ftelse_fra_Rejsefeber?="
    b = TMail::Unquoter.unquote_and_convert_to(a, 'utf-8')
    assert_equal "[166417] Bekr\303\246ftelse fra Rejsefeber", b
  end

  def test_unquote_base64
    a ="=?ISO-8859-1?B?WzE2NjQxN10gQmVrcuZmdGVsc2UgZnJhIFJlanNlZmViZXI=?="
    b = TMail::Unquoter.unquote_and_convert_to(a, 'utf-8')
    assert_equal "[166417] Bekr\303\246ftelse fra Rejsefeber", b
  end

  def test_unquote_without_charset
    a ="[166417]_Bekr=E6ftelse_fra_Rejsefeber"
    b = TMail::Unquoter.unquote_and_convert_to(a, 'utf-8')
    assert_equal "[166417]_Bekr=E6ftelse_fra_Rejsefeber", b
  end
  
  def test_unqoute_multiple
    a ="=?utf-8?q?Re=3A_=5B12=5D_=23137=3A_Inkonsistente_verwendung_von_=22Hin?==?utf-8?b?enVmw7xnZW4i?=" 
    b = TMail::Unquoter.unquote_and_convert_to(a, 'utf-8')
    assert_equal "Re: [12] #137: Inkonsistente verwendung von \"Hinzuf\303\274gen\"", b
  end

  def test_unqoute_in_the_middle
    a ="Re: Photos =?ISO-8859-1?Q?Brosch=FCre_Rand?=" 
    b = TMail::Unquoter.unquote_and_convert_to(a, 'utf-8')
    assert_equal "Re: Photos Brosch\303\274re Rand", b
  end

  def test_unqoute_iso
    a ="=?ISO-8859-1?Q?Brosch=FCre_Rand?=" 
    b = TMail::Unquoter.unquote_and_convert_to(a, 'iso-8859-1')
    assert_equal "Brosch\374re Rand", b
  end

  # test an email that has been created using \r\n newlines, instead of
  # \n newlines.
  def test_email_quoted_with_0d0a
    mail = TMail::Mail.parse(IO.read("#{File.dirname(__FILE__)}/fixtures/raw_email_quoted_with_0d0a"))
    assert_match %r{Elapsed time}, mail.body
  end

  def test_email_with_partially_quoted_subject
    mail = TMail::Mail.parse(IO.read("#{File.dirname(__FILE__)}/fixtures/raw_email_with_partially_quoted_subject"))
    assert_equal "Re: Test: \"\346\274\242\345\255\227\" mid \"\346\274\242\345\255\227\" tail", mail.subject
  end

  def test_decode
    encoded, decoded = expected_base64_strings
    assert_equal decoded, TMail::Base64.decode(encoded)
  end

  def test_encode
    encoded, decoded = expected_base64_strings
    assert_equal encoded.length, TMail::Base64.encode(decoded).length
  end

  private

  def expected_base64_strings
    [ File.read("#{File.dirname(__FILE__)}/fixtures/raw_base64_encoded_string"), File.read("#{File.dirname(__FILE__)}/fixtures/raw_base64_decoded_string") ]
  end

end