package main

import "C"
import (
    "github.com/ProtonMail/gopenpgp/v2/crypto"
	"github.com/ProtonMail/gopenpgp/v2/helper"
)

//export encrypt
func encrypt(userPrivateKey *C.char, message *C.char) *C.char {
	key, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	userPublicKey, _ := key.GetArmoredPublicKey()
	armor, _ := helper.EncryptMessageArmored(userPublicKey, C.GoString(message))
	return C.CString(armor)
}

//export decrypt
func decrypt(userPrivateKey *C.char, passphrase *C.char, armor *C.char) *C.char {
	passphraseBytes := []byte(C.GoString(passphrase))
	decryptedMessage, _ := helper.DecryptMessageArmored(C.GoString(userPrivateKey), passphraseBytes, C.GoString(armor))
	return C.CString(decryptedMessage)
}

func main() {
    
}
