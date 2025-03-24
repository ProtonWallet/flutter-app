import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/scenes/components/page.layout.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/message.sign/message.sign.viewmodel.dart';
import 'package:wallet/scenes/message.sign/sub.views/message.view.dart';
import 'package:wallet/scenes/message.sign/sub.views/signature.view.dart';

class MessageSignView extends ViewBase<MessageSignViewModel> {
  const MessageSignView(MessageSignViewModel viewModel)
      : super(viewModel, const Key("MessageSignView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV2(
      backgroundColor: ProtonColors.backgroundNorm,
      cbtBgColor: ProtonColors.backgroundSecondary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// header
          context.images.iconSignHeader.image(
            fit: BoxFit.fill,
            width: 250,
            height: 175,
          ),
          SizedBoxes.box24,

          /// content message
          if (!viewModel.showSignature)
            MessageView(
              btcAddress: viewModel.address,
              onPressed: () async {
                if (viewModel.messageController.text.isEmpty &&
                    context.mounted) {
                  context.showErrorToast(context.local.message_empty);
                  return;
                }

                final result = await viewModel.signMessage();
                if (!result && context.mounted) {
                  context.showErrorToast(context.local.message_sign_failed);
                }
              },
              controller: viewModel.messageController,
              isLoading: viewModel.isLoading,
            ),

          /// content signature
          if (viewModel.showSignature)
            SignatureView(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                  text: viewModel.signature,
                )).then((_) {
                  if (context.mounted) {
                    context.showToast(context.local.signature_copied);
                  }
                });
              },
              controller: viewModel.signatureController,
            ),
        ],
      ),
    );
  }
}
