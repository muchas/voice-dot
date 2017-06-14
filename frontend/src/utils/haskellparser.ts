import * as $ from "jquery";

export class Parser {

  parse(value, transcript) {
    var url = "http://localhost:8080";
    var processed_transcript = "";
    $.ajax({
      url:  "http://localhost:8080",
      type:"POST",
      data: JSON.stringify({"t": transcript}),
      contentType: "application/json;",
      dataType: "json",
      success: function(data){
        console.log("succ");
        processed_transcript = data.responseText;
      },
      error: function(data){
        console.log("error");
        processed_transcript = data.responseText;
      },
      async: false
    })

    console.log(processed_transcript);
    return processed_transcript;
  }

}
