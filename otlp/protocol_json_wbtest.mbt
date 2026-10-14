///|
test "protocol json decodes Base64 identifiers" {
  let span : @otlptrace.Span = @json.from_json({
    "traceId": "AQID",
    "spanId": "BAU=",
    "parentSpanId": "Bg==",
  })
  assert_eq(span.trace_id, b"\x01\x02\x03")
  assert_eq(span.span_id, b"\x04\x05")
  assert_eq(span.parent_span_id, b"\x06")

  let empty : @otlptrace.Span = @json.from_json({ "traceId": "" })
  assert_eq(empty.trace_id, b"")
}

///|
test "protocol json reports invalid Base64 at its field path" {
  for field in ["traceId", "spanId", "parentSpanId"] {
    for invalid in ["abc", "a!b=", "====", "AA=A", "AAA=AAAA"] {
      let json = Json::object(Map([(field, Json::string(invalid))]))
      try {
        let _ : @otlptrace.Span = @json.from_json(json)
      } catch {
        JsonDecodeError((path, message)) => {
          assert_eq(path.to_string(), "/\{field}")
          assert_eq(message, "Invalid base64")
        }
      } noraise {
        _ => fail("expected invalid Base64 to raise JsonDecodeError")
      }
    }
  }
}

///|
test "OTLP json identifier encoding handles fallible Base64 decoding" {
  assert_eq(
    encode_trace_id_json("AQIDBAUGBwgJCgsMDQ4PEA=="),
    Json::string("0102030405060708090a0b0c0d0e0f10"),
  )
  assert_eq(
    encode_span_id_json("AQIDBAUGBwg=", false),
    Json::string("0102030405060708"),
  )
  assert_eq(encode_span_id_json("", true), Json::string(""))
  for value in ["abc", "a!b=", "====", "AQID"] {
    assert_eq(encode_trace_id_json(value), Json::string(value))
    assert_eq(encode_span_id_json(value, false), Json::string(value))
  }
}
