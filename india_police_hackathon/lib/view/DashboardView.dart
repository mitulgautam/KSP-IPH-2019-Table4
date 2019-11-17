import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:india_police_hackathon/core/model/VerifiedData.dart';
import 'package:india_police_hackathon/core/provider/DashboardProvider.dart';
import 'package:india_police_hackathon/resources/ConstantData.dart';
import 'package:india_police_hackathon/view/shared/CustomSpacer.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: ConstantData.dashboardProvider,
      child: Consumer<DashboardProvider>(
        builder: (_, model, __) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Search"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        model.clearListResult();
                        model.instagram = false;
                        model.google = false;
                        model.localDB = false;
                        model.facebook = false;
                        model.sliderValue = 0.4;
                        model.name.text = "";
                        model.showResult = false;
                        model.verifiedData = null;
                        var x = getImage();
                        x.then((_) {
                          model.image = _;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.brown, style: BorderStyle.solid)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: size.width / 3,
                            width: size.width / 3,
                            child: model.image != null
                                ? Image.file(model.image)
                                : Image.asset('assets/images/image_icon.png'),
                          ),
                        ),
                      ),
                    ),
                    CustomSpacer.verySmallSpace(),
                    CheckboxListTile(
                      value: model.google,
                      onChanged: (_) {
                        model.google = _;
                      },
                      title: Text(
                        "Google",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width / 26),
                      ),
                    ),
                    CheckboxListTile(
                      value: model.facebook,
                      onChanged: (_) {
                        model.facebook = _;
                      },
                      title: Text(
                        "Facebook",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width / 26),
                      ),
                    ),
                    CheckboxListTile(
                      value: model.instagram,
                      onChanged: (_) {
                        model.instagram = _;
                      },
                      title: Text(
                        "Instagram",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width / 26),
                      ),
                    ),
                    CheckboxListTile(
                      value: model.localDB,
                      onChanged: (_) {
                        model.localDB = _;
                      },
                      title: Text(
                        "Local Database",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width / 26),
                      ),
                    ),
                    TextField(
                      controller: model.name,
                      decoration: InputDecoration(
                          hintText: 'Enter name (Optional)',
                          border: OutlineInputBorder()),
                    ),
                    CustomSpacer.verySmallSpace(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "Tolerance",
                          style: TextStyle(
                              fontSize: size.width / 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Acccuracy",
                          style: TextStyle(
                              fontSize: size.width / 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          (model.sliderValue).toStringAsPrecision(2),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.width / 24),
                        ),
                        Text(
                          (1 - model.sliderValue).toStringAsPrecision(2),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.width / 24),
                        )
                      ],
                    ),
                    Slider(
                      value: model.sliderValue,
                      onChanged: (_) {
                        model.sliderValue = _;
                        model.verifiedData = null;
                        model.showResult = false;
                      },
                      min: 0.0,
                      max: 1.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OutlineButton(
                          onPressed: () {
                            model.clearListResult();
                            model.instagram = false;
                            model.google = false;
                            model.localDB = false;
                            model.facebook = false;
                            model.sliderValue = 0.4;
                            model.name.text = "";
                            model.showResult = false;
                            model.verifiedData = null;
                          },
                          child: Text("Clear All Selection"),
                          borderSide: BorderSide(
                            color: Colors.brown,
                            width: 2.0,
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            model.showResult = true;
                            if (model.image != null) {
                              List<int> x = model.image.readAsBytesSync();
                              String b64 = base64Encode(x);
                              var res = http.post(
                                "http://172.16.9.10:5000/image",
                                headers: {"Content-Type": "application/json"},
                                body: json.encode({
                                  'image': b64,
                                  'tolerance':
                                      ConstantData.dashboardProvider.sliderValue
                                }),
                              );
                              res.then((_) {
                                print(_.body);
                                model.verifiedData =
                                    VerifiedData.fromJson(json.decode(_.body));
                              });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (_) => CupertinoAlertDialog(
                                        title: Text("Error"),
                                        content: Text(
                                            "Please select an image first"),
                                        actions: <Widget>[
                                          MaterialButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("OK"),
                                          ),
                                        ],
                                      ));
                            }
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.brown,
                        ),
                        CustomSpacer.verySmallSpace(),
                      ],
                    ),
                    CustomSpacer.smallSpace(),
                    model.showResult == false
                        ? SizedBox()
                        : Text(
                            model.verifiedData == null
                                ? "Result"
                                : "Result ${model.verifiedData.total}",
                            style: TextStyle(
                                fontSize: size.width / 20,
                                fontWeight: FontWeight.bold),
                          ),
                    model.showResult == false
                        ? SizedBox()
                        : model.verifiedData == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                ],
                              )
                            : SizedBox(
                                height: 300.0,
                                child: int.parse(model.verifiedData.total) == 0
                                    ? Text("No result found.")
                                    : ListView.builder(
//                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            model.verifiedData.accuracy.length,
                                        itemBuilder: (_, i) {
                                          return Image.memory(
                                            base64Decode(
                                              i == 0
                                                  ? model.verifiedData.images[i]
                                                      .substring(
                                                          2,
                                                          model
                                                                  .verifiedData
                                                                  .images[i]
                                                                  .length -
                                                              1)
                                                  : model.verifiedData.images[i]
                                                      .substring(
                                                          3,
                                                          model
                                                                  .verifiedData
                                                                  .images[i]
                                                                  .length -
                                                              1),
                                            ),
                                            fit: BoxFit.contain,
                                            height: 300.0,
                                          );
//                    Image.memory(base64Decode(
//                        "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAGjASMDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3HAHalIPQUpAHGcZ6Uu2qENAOMGgjqKdtNBX60ANA56UAY6U8L3xRtI6CgBuPSjGKeFoC9h0oAaB70EYPSnbe9Lt7CgCMEg4Ap4HHSnBAccUoT0FADAD2FAGBjHSpAvtSMhIwCR7jrQA0AjpQAAakC89KAuD0oAYBzxSgU/b7UBfalcBgGO1KB6Cn7aAtGgDADjpSgEcAU/HFAGKLgM5zwaMcYzTwADxRtouFhuMdKADjpTscUYApDEwcUAY7U7FFACAYoAxS4ooAT2ox7UuKKAEpaKM0AGKKM0ZoAKKKKAIAh9KcEx2qQAClxincCHYR2pdlS0UgIghHal2cVJRQAzZQExT6KAGBMDFLsHanUUAIFA7UYFLmjNACYFGAKWkIyOtAAAB0FLiiigAooooAKKKKACiiigAooozQAUUZozQAUUUUAFFGRRketABiikyPWkLqBksMfWkFhaKjNxCvWVB9WFJHPDKxWOVHI6hWBxRcdmTUUjHAznGKWmIKKKKAG5Apc+9efeLozceKoYJJ7xYfse4Rw3Mkak7yCSFIBJ4656Cs0aVp6IS0TtuGGDzO+fbkmqUdDqp4SVSKkj1Euq9WA/Go2u7dPvTxL9XArxq+tdKDhP7OgbBHJQHHX1/z1qQ6RpBgBGlWIJHBFuuf5Ucq7m88tnGKbZ61Jq+mwj97qFqn+9Mo/rVNvFvhyMHfr2lrjrm7jH9a8yttN02EArYWucgZ8lf8K1IUtUXEdtChGOVQAGmoK25f9muy1O0fxr4XjHPiHTD/ALt0h/kahbx94WUlRrdqxB/5Zkt/IGuBvHVGICqozgcZqm05IwOMAcgYGP8AGjkR0RyhNXcj0c/EHwz0XUGc4zhLeVv5LUP/AAsjw6SQsl6cd/sMwz9MqK84MuFOBj3xk/561HJLmMDLc884AoUUbRyWL3kejN8TNAA+Vb58dcWjj+YFRf8ACz9LP3NM1Z/pAo/mwrzNXIckt1IHXmrtsd5AI9Dyf6Ck4pFvJaSWsjvD8UNPC5Gj6pn0KxD/ANqVXk+KaKcJoF8fdpYh/JjXDzKUYnPc4xxVd3JkGQccfh70rWZUcnodWzum+Kk2Mp4dk/4FdqP5A1E/xTvcEroEajHVrz/BK4uQgKRnHH056UkcIdMnHTkd8UWKWUUErs7KD4mazdSiOLRLJWJ6tdsQB+Ef0rSj8T+KJsFbbSIwRwC8jHOD7DjOOa4/TVgiyAQXwSecY5rdspyCACBgYx+VQ2kzkr4ClH4UbC6t4wcE/atCXAHH2WVuf+/gpJNS8XMxC6jpCDgAiwkJ9zzNU9u4aPOR656cf41EsimTAI/PHGafNc4lh431Q1LnxSyHfrlirE5BWw6D0wXNRyz+I4im7xECBjcEsoxuP45wO3FX3IRQQOcYwD0qpO6s20Hk8/8A6qlyaLhh4N6ozRf+JHfD+IpV65C2sQAP4qcc+pP+MqDXLhgp8S6iqgBTsigBJ6Zz5fX/AOtVqK1JbcRxwT/PNWUaNDtGAQcnPH6UuZmkqNLZIpvY6ntYt4o1Yljk4MIAx2GI+B+tQxaZe/aUZvEmtSBWDbTOoBORwcKOOnHTr61cmu4w+0sOO2P8/wCRVyFFC71OMY74pqTuS6MUtjNuNGC4Zta1xmA5I1GRQevZSB+lZc9mLcjdqmslcYAOqXHPHs1bF/dBJCM4APrwRXJa3q4CtHGSSMg+3SplN7HVhsHGdro2oNP06UHN5qRDEA51OfB7AH56mPhrSplOx7liCCc3krcjjnLHmvNRd3084SOSblugJ456+tdZoh1KwUGVnYMcgkknGffv0qVOR0VsBCmrpq5vp4U0hFzLa+YByTIxYnPqSST+dUb2w0aOQQJpVmMnvEvfr2+lWJtTmKFcNkjGScGs2FWa5WQgEk8nGSPanzN9TGnh4ptySHtoOlHBXTLMdCcW6np+Fbfg6xtrHxU4t7aOHzLJ92yMLnDpjp6Z/WmBCcHDEYyMnHaruhAp4utcYw1jOODnkPFVRbuc+LSVJ2R20hxGx9jTgcgGmyf6p/8AdNKhygPtWh4o6iiigDz/AMWjb4vtORhrGTr6h1/xqiwYrgEjjjPFaXjLKeJdOcEgG1mBIOM4aPj9aoxupYEAdec1p0R7eCbVJHNajGy3SsTwTj171fkbbaggZwBjk4qfU4FaPdjoQcjoKqzsBZAnjgAZFM76klJRRRj1JQCGOCDge9XrK6MrbQDgnjPB/KuXuSUDMRnBJ/zirfh27DXJViAASAAc/jk9OtUo6XPRdBez5kbd85Qkg4IPYYz7ZrOd1AOAM8d88Vc1iQIeh5IPJ47H61iM7SsFUdTjgH17UmhUY+6myWRiSSM4weRx3pYgSMtj6cmnpaSlcspxjqeOPalkTYBgZwAAQMAmpua8yWiK7A5IJPB454xVqzBB46jHQVCRkHABwRT2u4rK3Z5WIwMnHHaobMKlZJWbHXCO0gBB4GcE9KpySpEoLtgkkZwB39azb3WprmQrDKsSMDkg5bp61yt7q18l75Cb5xuBIRSTjqTj16/lVJN6HHLMYU9Gd2AJSSSSp5Hc81JfzrYW6tkjdkAY7k1nWPiOCJYbZLKVyAAXdNoI788c/Wodd1GKa3DQBzLE4Yxse2eRSfYJY+k43TL1m8kMgZmOT1B5ByfyrsbRsxhhnAPBPTA5zXF2mqW135c6YcMACAehHX6Uy+8QSQRtFlokkBAJBAPXp7Vm1qc1bG05JWZ2SeMdMtJDBJMxIJBKqSPpnpWlp2o22ogT2syuoODg8jv07V5t4b1E2kUhmjildicBwCCPqe+K0HlawMeu2TR24M4iltUPDqQOQPbmkrrQ5lUhLVHqDOzxgKcnqCTwDVJYJTcFnOADjpz1qS1k+RWHQrkHOcZxVtE3sT6enGaLXGp8qdiRD8m3IHAxzVTySspIOQTnOfWrEiiMk5GMc5FVxKQcEgDGBgd6QRvuiGeBI/mJJJ4GBxmrUJfyQ2SAfU81DeOGjDDjHOPSnwODEFJ5HAxU9S9WtTC1l5CzhDgkHJGcVzf2Z2mwVLZOcn1zXYX1uvmEsM546Y6mo4La36hRkHkAe9RLU7qVXkhoiHRtGto2EphBPqV5Fb7QQLGAFXgYAJFUVuViUKoPAGCOOeaiku2cEKR16gnOMVUbI5p885XuPlgR3yuBzngegpy2iIM4x39KiW4IIyeRk56UNO7txjA6EnOKrcajJIs7FUHAHA9MmptJfHjHT+PvW1woOMHrGfy4qBTkDBxnrgVLp8ir4q0ofxN5ydeo2Z/p/OqgjmxKfsmd2wyhHtTYjmNeewpzcqfoaZCcxj6CrPEJaKKKAOD8bo39uaSwPBhnGPXmM9fwNYayFWAPBznAHP510XjcAalo7E4yZV5PqoP9K5yRPmBB7jOBWi2PcwDTpWZacCWLBA6cEnp/n0qhexBLYrnHHbvVuEYbHAqLVFIjGCeM8A0Nm8rqSRzE1qXUl8A5Pp/k1Hp1qLe6DhuRnoevOfwqxMHD7SAoPOM/55qsisJQxJxkYwcc4H6VabtY92Dbha+hfvYpbm5jVR8hPJ645602a3jtioU5JPrgVfhlVbfcQScE8DmsudzI5Yg9eMik3pYxi3e3QsG7ZUKbcEg845/Gq8s6QxCe5YRx5OCxwPwHr/ntVfLGXOThQSc54wK4rxFqM+t3qWNszZjJBC8KOgyT+NSk2zkxmIjQjfqa1z4tDyyw2Sgx7sBs5z9MVmQ3d9exzPcttAJAjzn15Hr2qSLS7ewtQrNukTALEYyR1pxEUcZniBKSYUsOSD9O1J8uyPmq2NnUe5FBsxvCbmjOOnI/Om3et2FvLG00DqzEBgi4JA6nJ/kKvRtBGoMLqxY7WA5wfQ+hqjcaIt3JKsquyRjepByADx+A9qItX1OGU5N66lqFoYLVbqxle5gYEtGxyVOc4FWYxDqUaGNgs4cHYeCOehrGsZZ/C7tF5P2rTp2GJVUloyRyCPoOn1qze26JJFeWs5RmAYjOAR9BTlFdDNya66DdW0y80x01GwJCSErNGvI56sB68da01uWnjiS+UTJGuFyOeRx19KQeIp5LOOIwoSowSB1OOc+tVrq7kKGeIKsi8lCcduRipab0ZXPpuWYbBbcCaFgYySdm4kjjpj/P9KgltHuJMx3TxgEsydiOOPWo7DU0uraRwfKdckxg9Dx+lRz3UV5Yi9tpds0ZO/HGfUEfiOtSou+pUZtK6NiHxFrmmXwZJGmtQowMkkHPQjOMV12nePv3qf2gixwtgeanAB9/avNbDUJGgMgIHHzBuoHvTJiwUAqggPzFCAcH6+lPkOqGJktJHvqXsN7AstvKs0RUHfGcjB9aayEjPfPYnH6V45omrvo1x9psZWKMQJYWYlWHsDwP/r16xpepw6pZJcQEbCMsCRlTjoRUNWdmejRqKa0LDxs0eSSTg9aijcx/KCePcY/D/GrpwV656H0rLvgyLlDg5OeT0/yanlud1GLk7MqazeSJGREu5yeMDpz1qDSJZ2BMykZAOKmtUMiBpATg5xnqPU+9XEC5IUEAH0xzj86hx1N5x5I8qRV1CQxRlkHOBgH6e3SoNPeWSEySgrgkAcjoKvXEQMZJAyMnpntVVg0VsyKCM5AxkdadtCYNNWMTU9XmhutkILAkjBPb/GtyxvMWoeRVUkZwASRVOx0QT3JllIPzEgHkdatavELSDZETnBHyjoc1SVlc2lKDtBble619Vl2JuP0OMc9K0NBujP4q0RyCA0sg4OeTC5559q5RLRjIHK4JHc9q6bQEMOu6GS2AbkjAB5Jifqf8inG99THHQjGhKx6z2qG34jH0qaoLcDyx7cVZ8qT4ooooA4vxyMXGisOP9Jdc/WJj/SufIwxBB685NdJ46AC6O2Txekce8Ugrm3IBOBzjvzWi2R7OA/hgHAbAz9AKbdkEAEYGe+eKaSdwPU54zwKivywUYypyMACk0dVRe8jK1BADlOcdCB/k1n26M7bmGDnjPStGYl2JY9hweKbbskTKWHBOAByST+mKtOyPXhJxgX0tz9nCgkADGAMDNU5LMgkgYz+NdEsUbxBlXHAIBNVZIFZgAMHPpipOT2zTZxviKcaVpLyuSrSAqpJ6nHT+lcf4eMMVoHfBnuGB3dCOBgZPYVvfEVgdV0+ydgsSgM2SSOT1+tc/axSmV4raB1t4lLmdzwTxjH+e1aJLlPnMyxEp1LdC1fiaKJ1eTAMoKnpgZHGaGcpGGG1UPI29OOtQ3Vxb31sCz7mJ2sg5wQcH8arWllcRxskbsyEALkkkDPQCp5V1PKlN3sgtbi0kuJpUMqMX35xgEjA/LpVlddubKSR4QVOwgZP3lPWq0WmNHFIryFnGSAAR7jjvVs6dLexp5cbK+0quRg0mo3uzNc/QzrW9uUDxNLmKeTcO20nPA5p8TGGCa2mYMAAUY856k/SrU+iXsKgvE2wYyAOh7nNRxWM4jVY1U4IJLjJAH0/nT5o9Bcs2yC2EpCEAkAcgcEYGO1Ndf9MZQzbJchtxzgnPPv0H51u2lkd7FVHzdcDArYj8LRXyqVIBAySR05rJ10nY2jQdjmdOsIxKImKq5BBbpkcdvxqlaWsthfXittEDMQBnjOQc/kP0rp7zQJrHUIGWXzI1z8xOCCDkdvTNVdX003URaNyhYgnj3yfxqVWV2bRpNLQ42S5ewvXCAyQygK2c4IJ579cVaOqxuRbuDEDHjk8AY4/Otu60SK7sUaJiNhAIXGQQOT+fP1rkrjSL2AyM8YKrkFyCeAMf5+lbwlGe7FyNG/DOBbGS2lRgoHI6H29q6LRtbu9PRL2wYMhI82MnjHfj1rg7Vr21jeHaChclioBzx06ewrQ03UYrV/3zMI2JAAySeh4AzxSnC60N6E5Qke7WWuQ6nbpNEWXdwQTjB9B7VDqV6IYSX6AA4H4+teb6PrLWcgeFy0bN90dv8K6W81GW7t4xGgYMACD1BwcmuVtxdj6nL3Gs15Gzp1+LxCUUgdOQBnGeh/rWlFKqydevOcnjisvRLMw2qgKQckkZxjOea1ktnZiApPBGQPp+XersdVfkU2lsTz3cMMZLsBgEnNUUmju5P3YBAIGc9DmqHiSxne3IidlPXAJHOaTwxHLaW22b5myTyc45/Oq5dAVCCo+0T1N0TpbRgYI5xwPfNVWdb0ZAyoOAScD6VR1W5ZyFUMAR1BHXmm6ZO0S5YcZHB5J49KpwsrkewXJz9S8bJRjAHTsM1PaoYNd0QkMB9tA446ow59v/AK1DXYAGA5OCQMYHSokn361ohAIxfx989QRz+dCh1ODEKXsZXPV6hgGFIAwASP1qaoYhgsB/eP8AOpPmiaiiigDkfHaj7FprZI2369PdGH9a5iUYJyPyFdX46B/sizIxxfRZyM8Ekf1rmJVIYjJP0rRbHr5e/caK6Ehxzj60zUCMAE5GemamVcMMEE56Cor8HCjB/Hik9zsqP34ozZQAQCAM9+tVJQqbCc4DA9f881ckjYk4B69AMnHFVpoQACxI5yCTirW2p6sLWOisZSbYHIzgHAofcG3AgHOeeaoW8gihABzwDgUG4ZyVzt55JxxUM4akGm2cj4zkEniQTFEZDAFIbHByP/11z7m5e18q2EaliAVLYGKtaxem58RSQgLJGAR5gJ4Oe9ZVwbi2crEqSKWABBwQPy4qknofLYtp1HYiCQWt5GJldEEoLFehPHH0NXbrU9sgFrEQCcIMYx2x9az766jgQeY+0sR8owWJ9vy60tjDc3t3DKX2wxkEKQMtjPJ/T/PSpLS7ONXvsasaPYAtcDdJIQ2SenHStG18+7y6fuwOcjgVg6nJI+oOY5A8IABUdVbqfw6cVq2l28NrtIymAQAO1c81obwSudExU2hhcKw4JY9Tx0FUE0iGUu4LbcnocCoLR5JSbp3I3rtUYJAH09a27O2Z7cOylQOQD3GetcknJOyZ0xgnqVrbT4o2yVZuMgA8D/OK040mWMeW5QEjgdx6Zp9tA7ZITAOAOP5VejtiMZ5A5wTWLk2zoUUlYy7iI+WSUycZyRz+dUHtGeMMcHAB2gZOcdK6G5j8wBVA4A571DHG0DhkwSp6H0xzTT1G42RUTwrLHYx3bEGJwWIBwVGOhHesq4gtIWCvEp5OAwH/AOqux/ttXUwzKTGpICBe/fmsi+soZZi6KNjMCpYdMnv6Vo5W1TJjHXVHONo1ldyCVE8oEZ2qMZ9+lZWp6VbSgIYhG8eCCVAJGff8PyruINOX5FRegJyB047VUvdLjnThP3igHBPBPp+NVGrJO9wcF2PNLaee2vgpVhHvIAwCcEk5z2H5V6R4PlgvRIjqOMkZ7dKwbzSkUvJAgDBvmjIIIxVHRtZbw5qsgmR3juCNoA4Ukkk+3Sui6qK63OnC1HSlo7XPY47ZYgSMAdcA9BV2MKRwRnjjPPWvP7zxPe38xFipW2UBS5wDnHP9KsaZeagjOTI7Ak4Bz6/54qopvoetKlKUbtnWX0SEYYgkngcYxmskOqA4IAIxgcDualszPcrmZiCcDAOcdeaZqkAgs3KnkDrx1wcc+lbqGhpRumoNkAFvI+DsJBxzgnp/9cVdit4SuFYZHOAMc15nJf3PnlllZeTjB4/+vVqDX76AjDAgdeoJ/XH6VVnsevLATcbxZ6O1quOg6dz14pvkGK805wDhb6A/KMAZcDnjpyK53T/FMchVHwrE/wARI649TW22pJOLPawYi+tTgHgDzk5otoePjKFWnTkpLQ9Z6ioIT88nsxqftUMQAkkAH8Wa5z5EmooooA5fxyNugRsP4byA/wDj4H9a5aRxnJxz0ycmur8dDHhaZiMhZoic+0i81w7uQcgjpzgVcdj2MtjeLLCMPMGOM+wApl0VDAkAgc8Cq0dwBKoI5PQE07U5ViQOwIAGSRxQ9zuqU37SKIp7pEBIHH5Vgy3kk92IkJwCDwfrSvdm6ykakjOM9f61JYWgSYyODknPPQe9aJK2p68YRhHXc1FJACE4IwOT05qK7mS20+4ldwuUIUk4ySOPx5qcKN2QQM+grC8To7WKBQCikkgnAJA44qDzcVPlpto4rT0a0MjsdzyTsWJOeOxpftKrdtFLEPmBZZFBIxx19KcsqCN227JCBkMRgVn/ANqrctJGyCOSPjG3qOO/41ai3qfGzm222VNQtWe7aeNTuiYMp6lsHOKv22or5M10+9XIKBSBkHoMfUmqElzLJci3QMHznIGc45ODnj/9VWUjdTEsjKpEoZgRy3PSqa0szKLbZPpcdwrM0ykncWzjGQemfet23spr3KwttQ84xnHNYuoajds62kERjZ5NoYLnIP8An8MV2emoIUtbSIDeCGkYDnGOlYVNNTqhC73LljpARYYCSdoBY9jXRLCAoQAYAAx6Cn2UQiUMFJcjAJHQVcih2BncYcnPHpXJKOtzqjpZFaGPC4IGAcY6dKRyASFHUdcc1aZQcnH51XlAAIBxxjiueUbHRFXK0rLjIJyTyCPaqzsCScjoTSzuckAkDk4PH0qsZAMkn2+nPas+pqokrAYwT1I6nmhyNqqScA4GelQ+YScE9welMZyD6DqAKGx8pejYJtAIPGRnnFSyFXUg4yRgYGOccGs5JSp4ye1SefgZAyc54/lQmxchzWqyvZXoWQgIxIJA79Ocd65fUrgRarCjfNDISGBz09f8+vau3121i1HT5UwPOTDKQBgYOfrXmmrysZIZioGwlSDnIOQeecY4/Wu/C2kyJRtZneeGZkisHjuWIUTEgk9QD0/LFdbAITsaEkoQCoIGQCTXnnnHVHtFtUYIApbsMg8n6cfrXd6fIjQIm/DqAAOACAPSulaM9mkm4Kx0FipC8jHAHJHHGaq68wSwkIxjac/QA81LYyEvtGBjnJ57U3Xip0+RSAAQc8YHatolUk1VR5YQQSCOQSDQAB2qSYATSAf3j39zTBjPofStuVXPsIv3ULGCXAAyc9AP8K2rCWSO7sMMwH2yHKnkkCQHH+cf0rLtwCwBJBJ4PPPsfbpzWpDHsSOQnHlyxsMDGCGByfT/APXxRNaM8/MbOjJPsfRg6Cok4lk+v9BUo+6PpUSACeQAdSCfyFcB+ZEtFGBRQBzvjcE+E7wgkFdjZHswNcHIjNwATkY9K7/xoM+D9UxnIhJ49iDXK2NsJF3FRgDjjParjserl0+WLOeWB4r1CDj1xV3UoDcxiMnBPoatSWjS3ZIHA7ntUqxE3KqTjGDwPen1O+rVvOLRkW+lpaQZKgnOc4A5PekZFAyB0OemTW/fQfuc4HODzWNIhRSMEc56Yqm9TqhVc92RDIGBnPYZ4rP1WKKXTp4ZQoUjOT2P1PSrzEgZAGcnnqao6uiPoV6r45jIXJA/Cp0McU17N3PL4rZpL+6iW4ILAFUAyMdByapSCWC9kiKKXIALHqSAOn+fWrVlIiWi5jZHjcxs2OSRjJHtVeW2laQ3EUhZwQAG9OP04rpTtofFVWuZk6QtEyzBj5ucNgcAECq87pNA4WdgQQygDLZB7d+tacP2u+lFusiRxuQHdhggcZA966PSdO0e1kWJIVYxnJZjkkis5SUVcdON3oytoOhrLFbXVysrXGAxEhwRnkjGAK7vRtMhS4dyvzcHk5P0qCyCXN2gSPCrySeBjPQdq6DToQGmkBGA2BjkEVxzk5O53wiki4saIoAwMc8dqicnbgDoM8U9txIAHTsRSiIkEn06CspO5vFJMqMScgjGcVWlYnJAPfv09+K0GtiTngZP6VXltiAQTjI7D/GsZK5vFpMxJgS2QTgg5596quSGwABxwM8da1pYQDyBnIA4yaoTQnPGSOtc7VjeLRU3HOSccc4xSOx2kDAxgDH9aV12rg9QOnrxTlgJBySST0H+FL0LGKxIyM+vSkZ2CkkEdQB9frVgQEJgDAPQY5prwOQRgkZGMGmiLozpJSXAORgckHrzXI+JdOEUZmRcBnGBgHJOeK7aWzYgsqE4GQO1Ymu24k0a4LYOwcAnuAetdOHk4yQaNF7QTbto2xLcSzLGACo5698Zz16VpabZ3Kv5ssJU5JAI6cfpVbwWrS6ZbP5RQyKFyBgAeua7gQpG3lbgwAPKjjOOleitz06FblgkkZ1oHikIYnuRzj0pNcf/AEKQA4JHALY79P0rSZURwQBycenFZOvljZOE2kjJHHQ847VtFHRQ96qm0eduAHIHTPGDninJAz4IX5c4yeBSMhV8EnJ5yevNa1jCoXDDGSDjB5A4z+P+FdGyufTSnyxTI7G1IKlgp5xj168//WP1FbE1sE0y4fYPljLDJ4BAz/T9Pep7K3yoJUnnIwegx/8AqrSurZRpV6Cq8wPwRn+HvWUpXPFx1fmhJHr8Z3RofUCmLxO/4fypLVt1pC3qin9KcB+/b3Ari6nwL3JaKOKKBGL4sGfCeqgdfsz/AMjXO26eVCuAeQOOnaum8TIX8Maoo6m1k/8AQTXPrg20LAYzGpGT7VcdjtwbtdECINxOACefWqkak3Z4JA6du9XwCCTx0xwKpw4N05II5OO9PqjrcveRLcEbMjtzx3rLngBUkLggnvWrMCwwAQMdqqFMkjj8aGdUJWRiSAqxUcHnHFcd4hvZXJtjujCnJJ6Hmu5vLcuSQSCDnJ+tcfr8DpYXAaMk7gxYKSV68+w/+tS0ujPGzfsmkzhZVeSCSKORYyZN/PGe5qtC7QPuk4Cgc9gOKa5Y5DOJCpJJIIGOPxqGELcKYndl3dVUkjqP/r/rXWlpqfItNvU6u1trbUDHtJUggsRwQa6HStAiSN2jkdyxyMnnPeovDdsjmNcAIQM8ckV6Fb2EUcexFAGOTjHauKc9bHbSprczdN0polCKSBgBievvXRQWyRx7E4Uck59qI4kjAVBgeuKq3yahcqLayKRoeHdwcge2O9YN9jqSSItU1nTtIjczTr5gBITOTXJ3PxFt0EpRcBQTyDgDPX6e9dCvhWxhYvelrqQnJMmCAeKp6kmgwqY5YLRQQQcgA4+lRddS1e+hyk3xTihCkRl3IBIUEgc9M9s1BH8W4JGImtHUDPPXoeRjJx61fkvfB0C7TBaM3QFAM/zqlLbeFtQCtDYxEAEDYQccen+elaL2TWqKSnfQ0rHx7pF86IXZHPHAHB59e/8AhWtBe2t4SsUwYgZxjnFcvbeENCll327mNyMhSeAfbHSt7S9AWwuA8bBjjB754rmqxhe0DeMnbVak08XzAEYGcA49qkVkXBwBxnPpzUt6oHOOQCTWdPcKiEg4xjkema57JGqehNc6zY2JCzPngEgY4696zZ/GujQAASrjuMgECsS9tobqV2klXDZByeQDn9eayofCWmOzebfsSxyMjnnBx+ldVOnTavJmE5NPRHWwePdHDZLLjgEbgCee1WNUXTdV0O9vtJnWWMRkyRZBZSQevP0rll8AaQ+HW9uCrE5AwcHrjOKSfwvPocEl3YXsrw4BlT1APIwByK2UKSaUXqFNyvdo7rwwhi8MaejlcpECDnGBj863I1L/ADAn0Bz2OK5/RFS80uFxbXIjlXCsAduOP0rqraIoBGV4GACeO9dcU76nqQkkkVhG7SAkYGeBknHNZHiScW9uAScEAAEdznr6V1BiEabicYHQjp1rk9eja8bylJxjA47gGtorU9DCSUqib2RyaIkuxuFAYKRgHt2z15+vUVs2URbBDc4A657dPrj6fSs2TSri3XcgYlQSVAJycDnp9f0rR07zEx5ytkcEE85wP/r1rLbQ9qtJSj7rN+zhwgIUcgHJ4HTrV+6jJ0q8BwMwuDxwPlP51XtnHBAUHODgE+lXJX32k6cktGwwRnqD271lbU8HEttM9E0tt+lWbesCH/x0VP8A8vB/3R/M1U0M7tA04+trEf8Ax0VbP+v/AOAj+Zrl6nx73JaKKKQjO1xPM0DUEHU20g/8dNcnYyB9NtC3UwoRz7Cux1Nd2lXi+sLj/wAdNcNpjZ0exYE826H07CtIK52YTdmgVO0kjp04FZsAJuZMYHJ6Voq4MRBxnnGT7VSsh+/kJB6n2oaszpfxosOoSMk4zjvVQgk8HHOeOKnnfL7VAH4UxQR1H5nAoaOhXSMu+BEozgcjqc96ydcv1JGjWqbriSPMhIAAByK37yIlhtA6g4AziuRsHJ8c3plBbYAQSOg/wrGq2mrGVdc0bHmmrabLY3E9pPG0ckSllYDCkE9Pr7Vz8DmNtxCgBR1zyOD655/z0r2vxJp0Oq3BZHRJFyGDjAI/pXBar4bgitDcIxcggccjIxnpiumlXi1ZnhzouN2dD4Tnc3sES4EYA5B+nFerwoAgJPJ5POa8h8Bq8l1EWXGGIPPYYxXr8YAUDHA4rjq/EzoorQnXA5IPTsKrz3QiRiMDHJJNPckJx/Osi9QyqysxCnrj0zWLZvGOpyeseJ4ZbuWK51L7HYxEhxFgyykn7qj3rltbn1P7E0umeGryG1VC4ubqIlmXse3XINdjL4V8PXc2+VWacAAszAEEZwR6EZ/Woda8K6jf2yQp4iv3tVXbsaTdgY6AkHjFdFN01ZszqKbdkjx/To9Q1/VobGBo/PnwoLKAO3JIHStC/wBE1jw5qQS5iMYBwJIR8jDPA4+ldJpvhy78J6uuo2jLNJGpVfNTKgnvxjkUmv3+u6xE0d5cQKsjAlFBIA7Y9DW8q0XK0VoOFOad2w0PVJZp4ldGV8ZJHQ4/yK9NsFLxIRnkZP6V514V0qVBvLF0Xuw6D2/PFelaUhWMKRwM4/OuGoouTsdTeiK2pQOsRxgDBA9cZrgdd1UW0RIYgY5x1+ter3VsJI+nOMYNeSeJtJmF/KoAXaC2CDgjJ6e9ZwhHmXNsXGTs7HH3+uTAYTcgYAg9CRnk/Ssj+0Z2Kl7ic47hzwPb0/z9K05NIuriRt7xsXztLE5UZ6dOO/FRv4Xv0xtMLDg5Vif0xXrU1Sijhqe0bLtrqWqaXFHM7XCRyhWiaYEqyngHPQfz46V3vh7VTqcBjmCsGIRgDkHpyDmsWXULyfwra+H49KQhYxG00hBK/wC0Onr2qz4e8Jajpd3Fc/awyEZ2ds5HbPtiuer7Nq+zOmg5aKR6XZzC0SG0WRY4QBtj7jt+Va8RC4YgZ7fnXFFNQXY/lkOucHd16cHBzXSWnnyW6F2wSBxnH1/Wt4K6TPW9muVMkvrmV0KR5xwOAeRg/hWbBZOJjJJ0JzycHpW0kAReQOCOp9qXYpGD1GRgDtitFsbwqqCtEpG0R12nPQjoBg+/emNpUYzhAB0BrTESDOBgD1PFQT3SRfKXHGTkUXaHGrNu0WUHgaFCecDJ4UZ+v1qk18VMiBSCAepPTmtaMNcrwOvQk8fkKkTSIy24opJ6/wCTQ2W6sVFqe52vhlt/hbSWBJBs4ev+4K0CP345/hNZXhE58IaRkjIs4hwMdFArWYDzVOOSD/SuV7s+Ql8TJOfailopEkF2N1pMvqjD9K4HSCG0SxPHECcZ6cCvQZhmFx6qRXnWjMRo1koGNsQUge3FXBnVhd2XwAFOD2/Wq1qMSyknqSBVliNpwSAB3NV4AQzEDOTVPVnW/jRMqDGQME89KTy+Txz+dOXI7DjrnmnAn0x6dhQ1Y3uU7mNipOSDjHpWJa2P2XWlvSpYyDax9s5HFdK6gqQQB+FZmxkkOSCAcisaquroiaujjPGFwI72WIDhuCRgHP4Vi6XYXdzAllEjuspGCRkDoM5P866DxtpkzzjUYE3QkDeBn5SKf4S1GNnhhIAdlwuRg547etc8XbU5p0046FLw9aLpmtvZMgV1OcKO2RzXo+BkYBwexrmryxEWtxXiKAThWOOcE/yrpICCAPyzTk7u5zxXKrEuzKYx+AFVJbdXUjH09q0QAQAAetJ5eMY/Soa7GsXY5i80SKcEgMpJ5Kkg9PasObwzdCQvBqd3GCCAu/jj8K72RFC8jOBxx7VRnKoTgD8BWextFtnn03hTUX+WbU7hlPJyRnpg/jVmy8KWVsQZneYg8bu9dNKSWOcDmoJCQMsMcZ561PtGtEaWvuOtLKBItkUYVcEYwMfyrds7YIoIAAGOcCsSzukecIjEkEA4Fb8EpAAJx681pGV9TOcbMlmjAj+XjAP41xPiWyErRTEYOCCQM/0ruHJMZwMZHU1i6hbG5heI9RkrzwCBSnfoENzgrjwxa3qgozRy4+8uP6CqreFtbsgWhkimQEYD9QPXIH9K3ba8UyvAflljyGB4PBx+Va9vclo8EHBwOuRUxqyjozVwtqjk7XRtWlkAkeKNAeSMk9Rx0ro4LR7OFS7s5A5J+p7dq0wVJBC89Rk4NNcBgUIHIFKU29AS1LFqglt43CkY4yQMmr8SBB0xjoM/4dKraPH/AKMykZAYgZ7CtB1wMkHpkYFevRfuI7Iy0sNxxkAYAPbHagqckce4JpSACVA/EnigL3Axyece/rWqKTK13cG3hLcnGTgDJ7965yKaW+uMsWCggAE9ec/j3rT1WcOCg6445HrUekWyBlOBnOCQOaV0d9JKnTcmtTZsIvLXgZGeoGf1rRRfY5HqajjjC9ew4zj/APXU64xg9PbvUnl1Z8zbNTwiT/wiung9Vi2HnPQkf0rYf/WJ+NYvhDjw3CoAwksy8DHSVx/Stp870x6n+VYPdngS+JklFFFIkawyp+leb6SAulxrjG15FAPsxH9K9JPQ15vpwC28ikjK3M449BKwFXE6sJ8TLTEgEYI9CBSQAEkAgfXtQSdpBB/GmQkhjg4yccCmtzsteZaUHGQOn4Um4YwBz6gUqYxyOT60YPQZPvVtGg1s7SSO3APFUSQGJP6Cr5HynHH61VeIlsNn27VnJXVilZ6FARXk17GltHHJbyZ81JCAMDqfSqmqeGYr2+hu7GeO18tlYeWABkHOOB07VrvAjxNAThGBBC+4xSyaelj4SIgdft0efKVRkn0XHXH+Ncko2ehy1bxZHcIZ2LEDOBgj1Hep7ZiFQEYIA5z7VWgkYxpHMAspUFlzyDjmrUS4IHTHFJaowtqXkI2jHH0pcgDAI6VEpKjByee9N81RwCPpU36DSYTnCkg4FZkxJYknj9auSuCDk4/Ksu8nVFZmIVQMkk1EtEbU0yvcTrECS2O4yawbjUJLyU21uCxJAJHPGeoqtfX8uoytb2mfLBwzjI/I+laelad9kiUYBfAJbvWPK3qzquorXc2tA0uFUwzEyjk5PP5V0K2gjGVGQMcYwK5yORopBIjFHA5Iq6l7flgy3EZAIyGHJGK2i7aHPO7d7mtOAE5PI4IH0rGupxE2QcHk46AVfW5eVMuF5JxjnJwORWNfqFVpHO1Fzkk4AH+NKo3bQILuYfiCzicNqtrhbhAFlC8bh6/Wm6TdJdxjaRuAGV71Wu9RSWNooANh4JJ6jnpzWTDM+n3aTxMTHkBl9QaztdXe51R2sdkHZOSMYGeKV5hwBng4yT7VBDcJcQCRD8pGeCOtV7iYAEAjkHAJwc9KhJt2Qknex1ekDFiGyMsxI4/z+lWmxkg4x0/HiorCIxafChHIQEjPGTUxGTj1PYD1H+Fe7S0ijVaDFBLE4A54B+tMmkCKckAY6k1MqAHnj8cVm6hLsAVWHAA9fWrvZGtNc0kjOkBmcsR04BwenP6VZ00ES4APB7nj+dQFXK5AOM9Dx2q7p8JVs4wR6Ek1Cep21GlBo21xjkY4zxx2qVANwGQO/vTEBI5GRjoelTxquRjPXsKbPIkXfCAxobKQRtu7kc/9dnP9a234Kf739DWJ4TwNMuVxjbe3HGc9ZCf61tyHBT/e/oawe54k/iZJRRRSJErzqxUj7Wg/hvbgHHb961ei159aFVn1NQuNt/MDn3Yn+tVE6cL8Y+RAqk4A+lRRknr6/SpZXBU4PbHeokIAJxz7mi+p2Rvzk8bAMASBz2qfAYAg/nVBpSCMA9emMVahlBUAn69zVqV2byi7XJwnynH449KqTEA4AHXuc1cUjHU49+BVOYgSAAe/Sm0hQ3EjQhSzE5HI7CmSSsh3KFLDocdKmAwMgHHuaZJED0HGDnispRT3HKMZbnG3Oo30XjezFyNts3y8EgHPQnPfNdqFAlIA59q5vW7SCWxmlIPnW5EqsDyCDmt+znFxZW9ypyJEDZHuKxnFRVkctSNndE0jYQnI79ay5LpkuFjAyCQPStRyCh4788VmzwqbhHI6Hnn36VzyTJiF7P8AZoy7kAAEmuDutSbWbmRGdo7SIkHtuIP9ea7TViZbRwowSMYHpXm+pRSW1rPFbghySwz61K1lZnRTVkzrdJsTLGJordlhGCoAOCPX/wCvW6lqUQAKAORjHANeTw6n450a3jaFybdwCigZAHpzjFd74NbUPFdrd/bdU+zTRKGCxkAgjqfQ/hW/sHFXuYud3ds17iB9pBIUYxnt0rmdY+32gL2d0innKF8dq6S08HS61azStrk5MchUGNwQSAOuO/tWc/wyvHiMrasGIJADLnjjqefSpVPqXCpS2bOJfWfFMMhxOqDnG1iR19KjWXV705vr8sDyYySAffr9a6c/D3Uw7EXUIQHGec4z6YxWZfeGH09g01+oIJBI6AgEjB69qdlsaKdPo7leJZIhhlOccYBpJZ0iVxIgAxwDwelcKPEGrid4IbglQ5UHrxnHX9a2rFr69iVL4kngAnqBj8vXpVTw7grt6ExqqTtE6Hw9qMpt5k3ZQSHaQO1bmnMNQ1+2s0XcN2W44ABzzWVa2UdlbhVGSQc9vSt7woRaXdxdFSWYbQcdOeQKzpxTqXWx1U03tud4QFYjgYOMAelIRz15B9+5rKW9klYtnGTkDAH+TT2unBPy9QM889a9NGqpMtTXKwoeQCB16+vNZErGaTcpLDOMAZ7VJKryDg/kD6UQxEAAhiBnJJ9sf5zTOinFQV+osURPAHUknJ5zWhbpsHTnr0606C3yOn5CrQgK9s89+aVtTKpVT0HLIFOSRj86mWcAgYOenTFVihByPTIwP60zy2BBJIHfJpnK4pmz4SObK/8Aa/l6DHXB/rW9JwF/3hXO+Df+PXU16bb9x/44h/rXRv0B9CDWEtzw6qtNofRQKKkgSvPNwTU9XXIyL5z78gH+teiVwS2wbWtbYnAF7/ONDQjWjPllciYHYWOfoaiTIHB6nsOauXKKkeF69OKjihJTIB4HPahM6qdVc12VnIL8g9e5FPiOCOfbilePDcDvjOKaEI4yeDnriqTsd6kmi4kwXrgfjSOgdgeex61WyTwOMegqWN8YyM/U1VyVo7lpIgTjB4/GrKWIYZPp3NQRSAckEe3SpzdhBgDp1xUu5nK7ehzHia0lisbuOErukiIzjk9eM0zwsWPhex3MSVXacnkEcYrVv0FyHL5xtJwazfDDCXRSoXaFkZQAOhyRWVROxnUvZXNMMRxnvniq0pG7J4PUY7VI2UYqR0PU1G4JOcdeOBXNJMmK0uV5WDLtznjv9K4fWbdob8OVOwnoe1dwycEY9wM1nahpy3kZVhg44OBkVk/I1i0tyfTIIZdPSNkUwsowCM4z1+lVbzw3HCxe2LxgggtEdpAI5HHapdLEtpEIJCSFOFJ9PrWzHcZjIJyCCcE1pTnpZkJ8rucbbJqfhxZo9K1J445CXdHO4Z45x2PAFSx+ONbtEETm3nG7JLgg4J6DBxW5fWUF0pO7y3PGR/WuSvtBnSUtG6Mp6c89abkrndSWHqK01qXbjxvqZk2xRwCFhyCpyD9c+ntWFfXs2pDF1KFQk5CjjFIdJvYmC5VcgYBOO316046RMoJmdQMgEA8kVPN5mvscPDVFGDRrUTiWFQsa8kEDJPr0qeOMPOW24CkjIHvWiqRRQeTCu0nJ5GSfeoVtxDA7FhknPJ5NDm5OzZyPlctEKZS7BEGSThRnvkV21hp62unxRgfN95iDkZPYcVz+haYDIl3KmQGyufX1xXaRAGMcdhkds124emoq51QXKk0V4YgAARyB0znFTNEAoGO+MAUxgySnaARgAAevrVhDuUHHQ5GBjPFdJcpPdDUhHHynAGeuO1SrCAvAAIzkUKME8Doeoz1qZeOB068DFUjOUmTwgKcHPPvipwFOcAcf41XHBwcHnOacrEDGOBxgdKRzS1dx7qB0/I8VEQDgAe3SpGJJAx+fNRk7eQD+NJsauXPB/B1pMD5b/wDnDEa6R/u/QiuZ8IfLda6uMZvFYD6wxj+ldM/K/iP51jLc8at8bH0UYoqTMK4tVK63rinHN0rDnsYkrtBXGMNniXWhk5LRNg9MGMD+lA1uQ3ZO3GPzp1uvygE8Ypl1nPXvUtuMDJz+HFSi02tgeIPnnB96rtDtPAq4epIwPpTSAD/XpTTN4VnHQpNGQMkDI4yTSAEAEZ6Y44FXCgPPHtimNEAOR9M9qpM6I109GRByowTn9aerbh1PXoeP0qN0IwADjtinxjGBjGDTUk2bcyGuAY3AwOCBx7Vm6FEba3khJ/5aMQT7kntWqyYBxnGOKghjCMcDHOelRUehlUknohZoywIx+OMc1WbKsQRxnNXJBk8jHPeoHUEYx9cVyMhOxXIGQcHGPpTioIwee1KUI6D86Yx2DnI5pNJDvfYZJAM5Ud88VTZ5IZApzgjBwK01cFeo6Y461FcWyyoCowwIIJ6fhUtdUNeZUmQypkAknkYrHudLnfLRzsp9CcYzXQoSg2sDwKqzk4yBj3x7VMjSPkcqdIu0cF7ncemcnHSrB0qZIyxbcSM8GtRiQSMk89aZJO6KQDwPXisuZ30NNWZaW5QsX5IHJPWnWelyavdrABtiXBYnAGAR+tPZJr24WGFSWZgMjOAOck12emaZFpdksSENIRl37kntn2rrw9Nyd2VGKTEWzjjgWGJQiRrgYzn65qWFdoCkA4wOPpVgAAYJHI6ZqMAK+FB5OcHivS6HQnpYjliOCcHrx04qLO04BwAD0HFXwoIGQOhyTUUsBHIAHPYYp6CUujGIScH5snHTtzU6deMYPIx1qvEPmxgdT2561OvGRjng/rVLYJE/OBnPQdOP8mnAgd+M+uajDrwMdwOf/rUrAkcfhxUtmD03HNIMcHtnA4qFiWbAIyfQk04IckkHjqPwp6oM4weuRjipbIckWfCYCalrKdzJE5/FMf8AstdLMpeJlDFSe4OD1rm/DqhPEGrAdGgt2/HMo/oK6d+FP0rKW55Nb42KAQOtFKKKRmFcbcAL4s1VcD5oIH/9CH9K7EVxuoEJ40vRn71jAcY/2pRQNbkNyMHjPXsKlhA25IA+tRXBO4EfUelSQ5VMk4/WpRS3JccEg0nGCCB044pQcH/E0hJ4x268UDsIRg9OO9IQSBg/XFO7k/1oYZGAOn4UFLQjIBJPoKAMcAflTsDGOvFJjkDHPbNJ6F3Y0qecgdKiKkMSP54qaQhDsA+bAPAqFhgZPPHeolLSxcW2xjYycH3pjAHkg/jxSk4Jwfr+dRkgH04zzWLNBwUE444PamtEGXkcUpPPOTxkYFSKcDBHANK3cFdGZcI0R3KTkY4NVhrcUB2TgrySSOn51p3SjafTB7+1c7fWqn+HI4PIzWc7rY0hZ6M149SsrlT5U6bscAkD+tVLqVASodcAk8MPSuWubVA2SuCCcEZz0rOljlzgMxAyepzWfM3odEYLodgrx7STIuAuCM89qz727RsKpBPAwCTzmsG3gYHIdgB1BOe9XI4iGGT1I6g/nUlpJHV+GUhYSJu23QO6M9mHcZ7VrXGqraRbnt5ZGHBWNckHucVzNpMInVhgFcHgYNdJKVlgW6ifcS2HAJABxn9a6adZxVkZ87UtdhbTV7TU8rbOyyJ96KQbWB9MGrIfHDDB5HIrEu9Pi1FMEmG5HMc6fKykdMkckVp6Bqx1GxaG8TbfWreVPxgMR0YZ7HrXTTxN9Gbc2l4ovK56DJwMD0qbIA+YdOKURKQSgI5yOf8APFIImGBg88k5rpU01oJyREqrv+UEAYOAPc1IEyemDipI4wowR9akCjrx06AZ7VSkJz7EQi5B3HjnjjmpdhRQCTn60E4G3B4564pTkcE0Nswk22MbBPPIyRQoA7AemSKdgFuTn05oOEBIwPpUXJJNAB/4SjUWzwbO3GPcNL/jXUP9xvoa5Hw+4Piy9Axg2URHPPDv+nNdcwypHqDUy3POrq02hw6UUg6CikZCjpXGawAvjKY55awiwMekj/412VcdroCeMEbOC+n4646SH/Gga3K05JAwCcHPWp4RiPg/XFQSEZAGKsRZ2Dr/ACqSthwOD/WgnPHtSgc4A/SggY/+vQNMTHOB2oyCcY6eppyqS2ADycYqYRrEMsBnHQ80bmtODkyJYSVLngAEnHXgVQ0qR726LsNkYJ2gnJwDWkZC8boM/MpA5x2rK0BsF0JIKhgfUHms53TSOiVPliyYOZZJH5+8QB7A01zwSR0/Gi2IMRIGCGIJ/GhhgEdPYCsW9TOKsiMnGTjrxzUDHDdRj2qVsgdh+NQPkjr7elS3qapCl8N17jmnrLjGCagJIOcdOaQsVBwfz4pthZbEkz5UgAc+tZV6CVIAGScZI6CrsjgH6nnnvVC5fqM+4NZTehcIu5iXaqBkggc8YqgIgWzjjPGBnFad0pIAIHPAJ9aouADg8d+vvWR0xWgxUAIx7ZAp6sQcKRgDI4OaiYlSDn0PWkDg5wRwMYqU0UkX4pBuAJBwOBxjNdNo0rTLNakAhlLrk8Bh3rjonIkBDDHAwD2rb0y5VNTtFaVow77MqDznqDVReplUVka4UhgSQCOgx0P4Uy2cW3iGP+E3MRUgjglTkfzNS3REVzIgI+ViBkc4B71latM1tNpt0rgGO5CsD3B4P86cHaRVF3djrvtJiA+QlRwSBmpUvEfBVgVYcEf/AF6qBsykDnPOMc4NMu7a6eBWtdiMsgLCQZBXvjHQ12Ju10bOEeprK6tjOPx6075ScA9PSsm7VbQxNh8MSCQxwKnVigwCxHfmrjNoz9ndXTL5AJAHb1oCYP09BVIXKjBOeuDgE1It4u4LlsnGCRitFVuQ6ckWCCBkjp3JqtPKEBBIxnsMVMZuQFXJ7Yp4DSMBJFlSep6U+dMm3Lqyr4ckB8WzDJ5sRkY44f1/Gu161y+m26W/imEoMCSylJA9Q8f+NdRVXueXiGnUbBfuiihfuiigxDtXJa7Fu8WWhJwPsMmD9HX/ABrra5fXfl8T2BBwTZzj/wAejoQbMoSoAQAKljGFA4pk33hz+tPjB28DNSXvsPIwcE06KJpDhTgHvU0VqzjcxAHb1qyFVF2qMDHJ6U0bU6d9xiLHAuCfm7k1XdyQcHv2FJO4RSxIwOmOc1TtbkXCsQCAGx83B/KmrbHfTpJK6JFcq/J4Hqc1lWsgtfE72pJVbgGRMnAJOQQPx/nWmyBQCOAMk4FUdW02W70+LULZQLuzfzYiecgdQfwqJxvqXUS5dRbaXE1xCwAaOQgAZx1qeQnHOOvHNZUOoJc6zIysCJY1lwOMEjvzWgWJH061yN6tHHZqyGsQAevtULkAH36jNSOeQM1AzDscetJjT1GE44BP5cVFIcE5HPoRUpUEEjHrUEoIyeRzSdzRWIZJB1zkA55qjM+44BPIxmp5yQBg9aqMQGznoeprCTfQ0iupVuSEwSTxz7Vmu4I3AEAdOKv3JJIAGc9eOtZ8sTYwQQcDtU2djeNrEJfJ44AHXHtQAWOQcfjSiPacEjjg5FWIoGOQFOADzjA60krbg2kJbRlpAQeg4/OrTO8F7aMvDCZDgDtkZp8FqUGSMkjr7UksQM6NjBVgQSAcYOcj3qo22MpO51OqRiLVpAG3AgMCBjgjPT+tYniJCdLjZRysyHOORzXQ6lGfMtJtv+sgBB7YFZ+o2wmtooyAwMqnGc/j0rS1pXCi9Ub1vPHGy+YMFgACRjkj6VPtlkinW62rGCdhQ8lcdT71nzL+7G7GAB+GAKnSdtgwcgc9TXXujrlTvqiG+DXOm5gl3xDkHPOQfWksLkzQByeQMEn+veppZFkgMQQKc5wPrVGwHls6AYHUADpSRcY+60y9E5JII4HIIGKe5wQRjqO9VY2IYqQeQRyakVwckEHB6AU7g46mhbzqMBiBkdemKtRYiVsytIpOfmOdvsPasV3IXIPQYwTirNszOdqnGOvGBVJ3MKlFWvc0rOYN4rsVXOPsVxyf9+GuqrjrIbfFWmnOc29wuc9yYzj9DXY1stjxcQrTaEHSikz7UUzAcBiuW8RfL4i0ps9YZ1/9AP8ASuprmvEEQfXtEyQATMCT0+5n+lNDSu7GbIryShUUknjgZrTt7QRRhpSCeuKmhWKEnYvTqe9UpdQWV5F8towjEAlc5PrxUNnZTotu1i9K3lW7OFJwCdoOMms1dXQwASR+VKcjy85I/Gnx3KzICzMzdsjH6Vh3XGoZB4zk4HOaVztoUE3aRfvHY6Y87A7lORzjAqrpj72dlOQxB455qW/YHRJlJABQkkn2o8PvCtkokI3L3IxTTVzde7Tbt1LkoyNuOfekhu2gRIGXILBRgdjVi5jCASAfK3oM81SlVleOQMQVbPJ61RmrTVjkvEyrpHim0uoVKWk6eWSOiuD0/HP6Vr21yJYwQcg8itC7s4NW0uS3uwCjsdhAyVYdCPpXMWSTaZO1pOxZ1OA54DDsRXLWjZ3SMJ09PQ3XbJ4z+VVZASOOoNTKwZRgjPPAphU5yOOeRWDehkkOiB2ADjjB9qbKg2nBxx/WlUlV5B6c9qinmIBGOvHShystRqLuULjCgYB69aoSElsgY61enYOPpznpVYISTgYx26VjfU2V0VnjJwcH8uKRrUnquOfT2rRihHAxznFTmBSckHOPbNOzaHzNaIxI9PLtggZPTjA7e3NaCWqooUjngZNXhEFOAo4PpRtGOhxk+lLl7ibZXjtwTzjgYxnvj0qO9tQ8TMFwVGQQORir6hQOQBxkdv505iNhAAIwRjBoSSBF5p4rvQtOmUlii7CSOAf15qKGIT3aRj+AbuBx1xmorO5jPh8xAAPBKegwAPerOihdsk7n55DhSTztH/181vFXaHRTu7Es6hCwOAOhPtUbExIxGSAM8n9KdLIvnsc5Ungg5FRTHEbL2INb+R6MU7K5YilLorqoOR17iqqhknYMeSMYqbSSr25VsnaeD0/L2q1biznupFSeKWRDgqpBK8d8UJESnyNoqQQSSSYUfKTnODnpUHNvPJE7EkE8k9a1nxcwT2pla1zlVkBCsBjqM1i3tpHZTRYuWnJXBdyCTjucfrVNK1wp1HKVmWN+YwB7kcZNSxOQMgkc88471SifepIJIGe2OKsIQGGABnAoVrGso9C9p8rf8JVpXBKsJVz6fIT/AENd7XBWiD+3dDmGci5kU88YMMn9QK72to7Hz2N/iuw0Hr9TRSHGaKZyDh92uc8TMU1DRGBIJuXQkehic/0roh0Fc54sIWTRnyBtviOTjrFIKZdP40OgPDhQCQOMt1NV4grCRdoWQk7hnoaqGZxKMMBgjpVS8kmg17b/AMs5owwO7uDyMVmeuqTT3LMeIpivA5J/Ws6/OL3cM4IzjoK05iGKMmCwOCBWZeKy3BLAYI4OfapZ1UbOV2S3bZ0NtrYJGDxUemLiI856EZ7U9gZNDdQQSuc4FRaU4MGScZHc5NPqjRL3JeptrNJNEY88jpj0qGZWRDkc4JPekjfa3BIHTjigTxmN4nYeahOPUg1ojltyvRaDNOhM2kjecSZJA6dTUGqWFvd2I2MpuYsAMvJB9DVi3uhBCVWPOT0JxipZfLig228CrLKQzbVwCcY5NKSTViZp82uxzkG+JvLlGHHGOgq2BkZH6UOi3UjpIpjlQ5BJz/kVCJTARHKNrY4zwD+dcc4cpFSk1qiwyfLgjHaqk6ZXIH/1qnaXKgEDA55qCR8ggggEdaxlsRFO5nOCGIA4zz2pVAzgZ9OOBUjAknAxketPWMkggVi076GtlYEBwMYOTniplBGAR7D2piKVIzk47U8kAggZ5GM4/rWiehDXYCOAQD7cVGSAM9cHJGKeST1H4DjtTGXI6jOMYx7dKUn2BJgHAHIxgEDscU13BQknA5OSaQgjAPTqRnFQyB528mAfMc5Y9hnrxSinLQuMXJ2RPY2r3WlzIhwXuBuO7gLjnHvWrIgijjjUYCnaMDtz0qGwhWzg8i36ZJbJzyeuaRrhob3bMytHgdOoPPWuyMeVI6qVLkZJHEfNCEEA88GkYozSKhzt+U+x9OKbdXnkWszrnzWBCcc80QLiBX/vAE49cUzZX3Y3S5RHOQ3Qseo6jFXLew07Tbya9t4lWWUHfg8Hv+BzWehMUpOfc+v+frUlyCJo3GQuQSO3Xn8aatYKtPmle5o3VoNQaPdEVGM5PPX8ao6hZpalEXaAV7AnmtBWW5kt9l1JCIm3FRgBx6H2pmoutz8i8sp4IHGKp2sc9NyUkuhjW5IBUg8YOTwKtqcMAM+vA4qrHlZSDjPr61ZBAkBGTxjOaEdstdi3ZtjWtFGcAXZ4+sTj+teh15xE5TVdHOP+X1ASD6qw/rXo9ax2PncwVqw09aKCBnoKKs4QQ5RT7Cub8Zj/AEXS2/u38fPplWH9a6OE5hT3UfyrnfGoA0qyY5+W/gxj/ex/Wgul8aMgSgSd8AnoKj1KeNZbW4cYCsE9+T+lRykkuM4APeor1RcaaWC7ijAgAZwR6ZrE+h5E7NmpHb+Y7RxybSRuyKp39qtuyNuLMeDnkVXsbyOJobiVmwVCDnp9av300cJt4YxmOQY3Mc4/E0OzRn70JpdCG1Be2lhHPBwM/wBKzNNPkSyRY2kEjAznrW0JrDRpY5Lu7RFkYIu4j5mJ4A96y9VAg14lVCiVQc9AeafS9zWnU5puKWjNEk7Q/APuadLErEXGcDGCcY/M1DC+VxjBI7CnuC9tJDnBI4571ad0KSaehNHCuI5SCGUggDnI96s3mr2VpJBHOwV5WCoCO57VVtb2MrGvPyAK56AGrktjbTRq0qI4DBl3DOCORj3p7o5prVcxn6mgF3HMqcMNpYD+dUbmISrtcDg4B74xWxdvsgdXjYgH5SBx7VkOfMTKnB59zms5RTOmj70bPYypxPZjBO+EjAYDkfWnK6ugKnORnrVtCT8h5zxgnFRSacFctbkKxGSpHBrmnS6oVShbVDVUY5POaeoI4APTrmmbzEdkqlWAGMjGfpUoYADgD2rns09UcrTWjGlexB7Hk0gGBxn6jin5JOMdj160AY5IPAzS6XQDSARjBPHf6UxyBkgng+vWnt6HA57/AEqnfzGGFypywUkDOOaZSV2kSxwT3cm2NPkycvjgVfgtI7QbUXlhknGOat+F76HVfDaeWipPDmOYAY+YdTn36/jTbg7HwxBAOCc98V1wgopNbm9B6tW1RVVzGxPAIbnmql3bR3EwllkZV43DIAP144qaaUbyR35AA5NQwxJetIr52AgEjOQfUZ702+x3WsuZli7fdYqFC9QBg9RU1vxbAH0wBUH2Z7eCKKaVSoJw54J+vv8AStDyTHbKFjbGBhgDSMpSSSSZntkSYGAMY4GD1qeVM2wI5KkDn9ajkB3ZI6nHJ6c9OnFTwkMrKR78DPOaa8im9EyHAIXJJxgDAP8AnFWha+WqyIcZHzKT/nFVcgKCexAJ9D/OrsVwxf5gMAYGBTtoRNPdFLyEDeY7bQM9CMj2NMZlIyoIA6EmtDy7eZyXzuUZwBgDHNDwreQrNbvH5W3IIHBpx7EqrZ2ZUViL7SiGAxfw556gkjH15r0yvNRE++xkIZVS+t+SMA5lUf1r0qtlseNmLTqpoMUU0rk9KKo4BlvzbR/7orA8bj/iQxt023luf/Iij+tb1oc2kf8AuisTxqCfDUpVclZ4DjGf+Wq0dS6ek0cxIwAcjH0xUluwaCSMjqOh+lQzjAIJPB45xRp75lZQOnBA7Vj1PpLXjcLTTTLaspcghsgAfpWpcWaX2kgRqu6PkEHnIHPSqdkfKunXzCVyQVJyAPWjQ9MfQW1BpLt7hJ5GmVW4Cg9hVLY56rk35hBNaCGOO6thJJG2QJVzgjoRnoap61I9xfwSHaAqjBA56/yojl+0tJKCDkkjBzT7397BC4JyDyDUtuxvCCjJS6k8RzGCD2HJNWkQyY2gkjg4GKqQAmBTxkjqBk1f0+RY7tVYcHj/ACKcXYVVtJtblS3sLiK6eUIuxjkg9avX0Kazpc+nxTSQzFfldDtKkdD+dQ3VnqUWvidLwCxZcNAR0OeoNKYXtr+OSB9zN97dzxWi00OaT50n1HWqTWNnHZ3DmVlUKXPJYgYySay54nti7qAwBzgHBxWvfmUqZAvJ6nOAKxIrwtcGCfaCx49MZ6VEt7HRQTtzDYnWR0dSACR0GK0VCiVRkAnkAmsqQLZzBZB+5dgQccA/XsK2I0RsNtBOAARTiujNqu10W3tYRtSWZRvGBnGc+1creOLPWZbNmBGAy47g+34V0M+6IxybSx6DjO33rnfFNsYL6z1NGIDr5UozxnqP69axrQ91tI4+V9XuTo3HX8ulICTkZHfgVUgl3KBng/4VOCOuenPWuBNLczaHsexHbtVK8UOhUjJ74FWyynvjGRiq8wy2ecZB569aVyle6sY2j6pPoWtfZ0Z2tbyRVMeeAxOARj6V3EkdvHKVkk3PydueT+FctZ6ct3qkczBRHbsGJJxz1GPers1tPfayskCKix5yxzuOeuSO3SuuDbidkYp67D7mVEuyyHAAOBnFOsj5FqWBZXkYk/X2qhdSMs8kZH8W0nPGavhSohjUZwAcDnvVrU62koq5qzZuoY0jQ5UjOQO2M/hVuXVYItQt9MeNvMlQspxlcDjGfX2qj9pewj3tEGVhnIOD+P8A+uteOSCe1juRsY4yDwcHviqSPNqqz8jMvY1Eo2DGDkgAD1qGL5WHvgcVcu5Y5QMdR3PHrVMAggAY57cdqXU6KbbjqROMSMOdoORxU8ZwASccEDJxUU64YkA8jPpT4yMAnAxwCBTv0LeqFSc29wxABDDHI6+30pl1dFWhkSJkhVhuA4Uc/ljrVqG3SRjkDcckA8fjip7a4s79ZrWGZGaEhZUXBKn3xQtznlJJ3sVtRklvdOtJrcmFIdQtWkUr99RMmQPTsfwr0MdK851dXsbRFhkIUzxFgecgSKTx9BXooPFbrY8fGq0k1sOooopnGVrH/j0j9hWP41GfCd6393Y35Op/pWvYf8ei/j/Osrxp/wAiZqx/u27N+XP9KfUqPxI5e/G0IV4z149qp2TFb/Bz8wIBJxyK0dQQGCJxnnBB6DpWSzeTcxPgD5snnnHtWUtz6em+aFkGoPJHcN5UjKSMkrwetaMM800cDb1KFRuLYJI9DVG/H+mKcEgjBJOMZpYA50oqpb93IMgdSAemaS3KnFcqdi/bwwRzsGZU5I2E4/Id6icIszRK2UI+U46VbvIYTMkxVQSFBfOcY7VHe27RujorFSAQw4GKqS00MIzs029yO3G1SpJGD3PFSMxikjcdQcjAximxIQwYAcjtzUk8Z245P1OP0pRLbTfqS6lJJPCrFsY5BBI5+tN0i+YEW8g3N2bHYnvT0jMtryMFR1ArMVWhuw4OCDwTVPuZqEZQcToo4ZY4JEaYylnJBPYE9PwrC1XT2f8AeoNsinIP51bjlmkbIk689QBmrEh+Qea0YyR1YdPzpvVGcJeye5gRypeQG1nC78AYI5yO/wBat6bcsjm2uPvpyCB1FQ6zDaq0c8F1bq6glhvUDHoay31zTNqyvqNpFPESDumUEjPI5I/Opjo7HXzQnHfc7NCjbmI6DgYqnrVgl/oE8aj96q+YmO5AzWVF4s0F4QW1vTkYgZDXKZz+dWbbxh4ZgkxLrtkeP4ZQwwR7fjVyjzKxwTcY632OWs7ktEFOQV6gk8c1fjlBAAPqOgFYOo6rpNtq9xJp979qtpmLKYo2O0k5I4Hb+tPg1uAjC218/GcpZynj2wtebPDVb6LQJVae9zeU4OOc8E8+9RXEoVWYHkDpnjpVCPU2bDJpmrMvYrp82D/47imy3F5K3y6FrjJxkjT5fTpyBQsPVvqhRrU7pNm5bwE2MQLBQwDEg457elaRuIYrFngVVdAcsR1NYjajfGILB4Y17AAAzZEZxwepH9KgmbXpYhFD4Z1nBIJ3xKPX/a/zx611KlJK1jpWIw9knIId1zdlmIyxLNgd8+3+eldNpjR+eVIYtjgAcYrnbODxBBlj4T1SR24GWiXHGectWjav4qimDp4RvBkYIa5hH/s1Wqb6jr4yjKNoyNY2KzQst2+997GMKSMAk4H5f1qSK1jsrNI5BgsxC49euKyPK8YzziRPC7RnII330Qx19M+1aSt40KbP+EZsjj+J9SAz+AU1fs3axxSxVONkpFbYEkZQBwSBgc4oAI65wc85x/KlfTvGLKHTQNKR25IbUmJU++I8fkaemi+MnjVTp2hx49b6U8/hFUOlI2WPpbNjLhQV44PTpTUwBjB4Pc0snh7xvJkbNAVSRj99Mcf+OilHhfxlkET6CgyD92Vvr3FJUn1D+0KKVrliJ44sMTtYDIOOtLZ6dZWf2m6tkEUlwd8rluSf8Kjfwj4tmiCPq2jIfVLKQ4/OTn8qWPwZ4oAKv4g04oBwP7PY4P4yVSpvuYyxlJ6mRf3U8+mXc0oG2NdwIOeFOc/Tj9a9YHQV54vgHW5UliufE8ZglBWSOLT1X5TwQCWOMjI74zXoY4Factla5x4utCrJOPQWiiig5Crp5/0UD0JFV9csJNT0G/sYigluIHjUvnaCQQM47c1Np3/HsfZjVyjqG2xwEugeLJraKHGixlFAJMkr5IH+6OKqS+C/FlwMPqmkRn1S3kY/mWFek0tGl9jdYqtFWUjz0+CvEU+0T6zpyBQQDFZMCD2PMhzTofAWtxxtG3idArHJCWCj+bGvQKSnfsH1ms1bmOLHgjUXjCTeKLsr0Ijtol/mpqb/AIQu6eIRyeKtYK4xhVgUY/795/Wuuoo5mZupN9Tj18ApgB/EGtMo6DzY1/VUB/Wl/wCFd6ceW1TW2P8A2EZB/IiuvopB7SfdnKL8PdFAw82qSD0fUpz/AOzUL8OPC4+/p8kp9ZLmVv5tXV0U7sXPPucyvw+8KL/zBbc+zFm/mTUq+BPCigf8U7phx/etlP8AMV0VFHMxXZgp4M8Lpjb4d0pcdMWcY/pVqPw5okRzHpFghxj5bZB/StSii7EU10uwQgpZW6kdCIlGP0qZbaBPuwxr9FFS0UrgNWNF6Ko+gxTsAdAKOKXNFwDAowKMikJAGSeKLhYMUYFMM8S9ZEH1YVG17aqfmuYR9ZAP60rhYkYMQNhAwecjOR+dSVQbWdMQ4bULVT7zKP61BJ4l0SJcvq1mB6+ep/kaLoLM1qKwm8Y+HV66xa/g+ajPjbw4BxqsB+hP+FO47M6GiuWPxB8NL/zEM8kcRsen4Uw/EXw9j5J53P8As27/AOFILM6yiuQPxD0o58uz1KTHTZbE5/WlHjuJz+60PWXHr9nA/maeorHXUVyY8Y3T/wCq8Nas31QL/Wpk8R6vIDt8MXo443yIOffnijULHTUVzi6z4gc8eHCox/FdqDn8qmW98Ru2RpFmi54D3hzj8FNAG7RWaJNXP/LG0Htvb/CigB2nSosDBmUEMepx2FWWu7dCA08QzwMuBXP32gT3edsgX61iS+A7mUkm5UAnoQKbj5hodq+q6dGSHv7ZSOu6VR/WoX8Q6NGPm1Wz/CZT/WuLHw5c8G6UfRR/hTl+GyA5a6OfUAf4UcvmF0dW/izQEOG1a2z7Pmq7+OPDqEY1KNs/3QT/AErCT4cQA/NdPn0Bx/SpU+HNiB800h9Rmjl8wujRb4g+H0z/AKTKQOuIWP8ASq8nxI0RDhUu3HqsWP5kUxfh5pQ+9vb6mpl8A6QpyYSfrT5V1YX8is/xO0dQdttenBxzGo5/OoX+KNgCdmn3LAdyyg/lk1rJ4I0dMYtgfqBUyeENIQYFon5Cjlj3DmXY55/ihCMeXpcp9cyiom+J8xzs0np0zKT/ACFdanhjS0HFpGPwFSpoGnJgi0jGP9kUWiF/I4lviTqLD91pUQ9NzMf6Co/+Fg6+5OzTbfB6Dy5D/UV6Auk2SDi2jH/AakWwtl+7BGP+Aii0Quecnxv4ncYSwh56EQNx+Zph8UeM5eUtwuewts/zNemi1hHSNB9FFKIEVicDntgcUWiF2eY/2347lXasYHv5ABpFfx9MMGeVQR2Cj+lephAOgoAA7Ue72C7PLjpnjuddp1C4Uc8iTH8gKWPw141dsvrFwPrOw/kRXqOMdqMe1K67BeR5iPA/iWUfvdan56/v2Of1p6/DjU35m1mc5GCPMJyPzr0sYoov2QXfU86j+F69ZdRlbPXJz/OrC/C/TT/rLiZuc9v8K76ii4XZxUfwy0RPvea31arUfw88Pp1tS31NdWKKOZgc5H4K8PxNtGmREY6kZq1H4U0OLG3TLcY/2BWzxRxRzMLGemh6XH9zT7cY9IxUyafZxj5bWFfpGKtUUrsRGsMSfdjQfRRTwABwBS0UXGFJj3paKACiiigAooooAYOlOAANFFAgwMUh60UUwAAc0goooAPSlFFFAw7CjFFFAdRaBRRSEAo/woooAXtQKKKBgKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/9k="))
                                        }),
                              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<File> getImage() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }
}
