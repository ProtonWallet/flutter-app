package main

/*
#include <stdlib.h>
#include <string.h>
struct BinaryResult {
    int length;
    char* data;
};
*/
import "C"
import (
	"unsafe"
	"fmt"
    "github.com/ProtonMail/gopenpgp/v2/crypto"
	"github.com/ProtonMail/gopenpgp/v2/helper"
	armor_helper "github.com/ProtonMail/gopenpgp/v2/armor"
	"github.com/pkg/errors"
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

//export encryptBinary
func encryptBinary(userPrivateKey *C.char, binaryMessage *C.char, length C.int) C.struct_BinaryResult {
    data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
    key, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
    userPublicKey, _ := key.GetArmoredPublicKey()
    armor, _ := helper.EncryptBinaryMessageArmored(userPublicKey, data)
    encryptedBinary, _ := armor_helper.Unarmor(armor)
    resultBytes := GoBytes2CBytes(encryptedBinary)
    resultBytesLength := C.int(len(encryptedBinary))
    return C.struct_BinaryResult{length: resultBytesLength, data: resultBytes}
}

//export encryptBinaryArmor
func encryptBinaryArmor(userPrivateKey *C.char, binaryMessage *C.char, length C.int) *C.char {
    data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
    key, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
    userPublicKey, _ := key.GetArmoredPublicKey()
    armor, _ := helper.EncryptBinaryMessageArmored(userPublicKey, data)
    return C.CString(armor)
}

//export decryptBinary
func decryptBinary(userPrivateKey *C.char, passphrase *C.char, encryptedBinary *C.char, length C.int) C.struct_BinaryResult {
    data := C.GoBytes(unsafe.Pointer(encryptedBinary), length)
    passphraseBytes := []byte(C.GoString(passphrase))
    ciphertext := crypto.NewPGPMessage(data)

    message, err := decryptMessage(C.GoString(userPrivateKey), passphraseBytes, ciphertext)
    if err != nil {
        fmt.Printf("Error in decryptMessage: %v\n", err)
        return C.struct_BinaryResult{length: C.int(0), data: GoBytes2CBytes(make([]byte, 0))}
    }

    resultBytes := GoBytes2CBytes(message.GetBinary())
    resultBytesLength := C.int(len(message.GetBinary()))
    return C.struct_BinaryResult{length: resultBytesLength, data: resultBytes}
}


//export enforce_binding
func enforce_binding() {}


// function from: https://github.com/ProtonMail/gopenpgp/blob/main/helper/helper.go#L392
func decryptMessage(privateKey string, passphrase []byte, ciphertext *crypto.PGPMessage) (*crypto.PlainMessage, error) {
	privateKeyObj, err := crypto.NewKeyFromArmored(privateKey)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to parse the private key")
	}

	privateKeyUnlocked, err := privateKeyObj.Unlock(passphrase)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to unlock key")
	}

	defer privateKeyUnlocked.ClearPrivateParams()

	privateKeyRing, err := crypto.NewKeyRing(privateKeyUnlocked)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to create the private key ring")
	}

	message, err := privateKeyRing.Decrypt(ciphertext, nil, 0)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to decrypt message")
	}

	return message, nil
}

func GoBytes2CBytes(bytes []byte) *C.char {
    str := string(bytes)
    cStr := C.CString(str)
    return cStr
}

func main() {}
