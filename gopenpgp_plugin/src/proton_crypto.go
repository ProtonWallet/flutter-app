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
	"fmt"
	"strings"
	"unsafe"

	armor_helper "github.com/ProtonMail/gopenpgp/v2/armor"
	"github.com/ProtonMail/gopenpgp/v2/crypto"
	"github.com/ProtonMail/gopenpgp/v2/helper"
	"github.com/pkg/errors"
)

type KeyArray []*crypto.Key

const UnlockError = "Unlock: %v"
const ArmorError = "Armored: %v"
const EncryptError = "Encrypt: %v"
const DecryptError = "Decrypt: %v"
const KeyRingError = "KeyRing: %v"
const SignError = "Sign: %v"

//export encryptWithKeyRing
func encryptWithKeyRing(userPublicKeysSepInComma *C.char, message *C.char, outError **C.char) *C.char {
	keyString := C.GoString(userPublicKeysSepInComma)
	arr := strings.Split(keyString, ",")
	keys := make(KeyArray, len(arr))
	for i, keyStr := range arr {
		key, err := crypto.NewKeyFromArmored(keyStr)
		if err != nil {
			*outError = C.CString(fmt.Sprintf(ArmorError, err))
			return nil
		}
		keys[i] = key
	}
	keyRing, err := keys.ToKeyRing()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(KeyRingError, err))
		return nil
	}

	pgpMessage, err := keyRing.Encrypt(crypto.NewPlainMessageFromString(C.GoString(message)), nil)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(EncryptError, err))
		return nil
	}

	armor, err := pgpMessage.GetArmored()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	return C.CString(armor)
}

//export getArmoredPublicKey
func getArmoredPublicKey(userPrivateKey *C.char, outError **C.char) *C.char {
	privateKeyObj, err := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	armoredPublicKey, err := privateKeyObj.GetArmoredPublicKey()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	return C.CString(armoredPublicKey)
}

//export encrypt
func encrypt(userPrivateKey *C.char, message *C.char, outError **C.char) *C.char {
	key, err := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	userPublicKey, err := key.GetArmoredPublicKey()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	armor, err := helper.EncryptMessageArmored(userPublicKey, C.GoString(message))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(EncryptError, err))
		return nil
	}
	return C.CString(armor)
}

//export getSignatureWithContext
func getSignatureWithContext(userPrivateKey *C.char, passphrase *C.char, message *C.char, context *C.char, outError **C.char) *C.char {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	passphraseBytes := []byte(C.GoString(passphrase))
	privateKeyObj, err := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	unlockedKeyObj, err := privateKeyObj.Unlock(passphraseBytes)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(UnlockError, err))
		return nil
	}
	signingKeyRing, err := crypto.NewKeyRing(unlockedKeyObj)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(KeyRingError, err))
		return nil
	}
	pgpSignature, err := signingKeyRing.SignDetachedWithContext(plainMessage, crypto.NewSigningContext(C.GoString(context), true))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(SignError, err))
		return nil
	}
	pgpSignatureArmor, err := pgpSignature.GetArmored()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	return C.CString(pgpSignatureArmor)
}

//export verifySignatureWithContext
func verifySignatureWithContext(userPublicKey *C.char, message *C.char, signature *C.char, context *C.char) C.int {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	signatures := splitPGPSignatures(C.GoString(signature))
	publicKeyObj, err := crypto.NewKeyFromArmored(C.GoString(userPublicKey))
	if err != nil {
		return C.int(0)
	}
	signingKeyRing, err := crypto.NewKeyRing(publicKeyObj)
	if err != nil {
		return C.int(0)
	}
	for _, pgpSignatureString := range signatures {
		pgpSignature, err := crypto.NewPGPSignatureFromArmored(pgpSignatureString)
		if err != nil {
			return C.int(0)
		}
		verifyError := signingKeyRing.VerifyDetachedWithContext(plainMessage, pgpSignature, crypto.GetUnixTime(), crypto.NewVerificationContext(C.GoString(context), true, 0))
		if verifyError == nil {
			return C.int(1)
		}
	}
	return C.int(0)
}

//export getBinarySignatureWithContext
func getBinarySignatureWithContext(userPrivateKey *C.char, passphrase *C.char, binaryMessage *C.char, length C.int, context *C.char, outError **C.char) *C.char {
	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	plainMessage := crypto.NewPlainMessage(data)
	passphraseBytes := []byte(C.GoString(passphrase))
	privateKeyObj, err := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	unlockedKeyObj, err := privateKeyObj.Unlock(passphraseBytes)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(UnlockError, err))
		return nil
	}
	signingKeyRing, err := crypto.NewKeyRing(unlockedKeyObj)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(KeyRingError, err))
		return nil
	}
	pgpSignature, err := signingKeyRing.SignDetachedWithContext(plainMessage, crypto.NewSigningContext(C.GoString(context), true))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(SignError, err))
		return nil
	}
	pgpSignatureArmor, err := pgpSignature.GetArmored()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	return C.CString(pgpSignatureArmor)
}

//export verifyBinarySignatureWithContext
func verifyBinarySignatureWithContext(userPublicKey *C.char, binaryMessage *C.char, length C.int, signature *C.char, context *C.char) C.int {
	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	plainMessage := crypto.NewPlainMessage(data)
	signatures := splitPGPSignatures(C.GoString(signature))
	publicKeyObj, err := crypto.NewKeyFromArmored(C.GoString(userPublicKey))
	if err != nil {
		return C.int(0)
	}
	signingKeyRing, err := crypto.NewKeyRing(publicKeyObj)
	if err != nil {
		return C.int(0)
	}
	for _, pgpSignatureString := range signatures {
		pgpSignature, err := crypto.NewPGPSignatureFromArmored(pgpSignatureString)
		if err != nil {
			return C.int(0)
		}
		verifyError := signingKeyRing.VerifyDetachedWithContext(plainMessage, pgpSignature, crypto.GetUnixTime(), crypto.NewVerificationContext(C.GoString(context), true, 0))
		if verifyError == nil {
			return C.int(1)
		}
	}
	return C.int(0)
}

//export getSignature
func getSignature(userPrivateKey *C.char, passphrase *C.char, message *C.char, outError **C.char) *C.char {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	passphraseBytes := []byte(C.GoString(passphrase))
	privateKeyObj, err := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	unlockedKeyObj, err := privateKeyObj.Unlock(passphraseBytes)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(UnlockError, err))
		return nil
	}
	signingKeyRing, err := crypto.NewKeyRing(unlockedKeyObj)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(KeyRingError, err))
		return nil
	}
	pgpSignature, err := signingKeyRing.SignDetached(plainMessage)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(SignError, err))
		return nil
	}
	pgpSignatureArmor, err := pgpSignature.GetArmored()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	return C.CString(pgpSignatureArmor)
}

//export verifySignature
func verifySignature(userPublicKey *C.char, message *C.char, signature *C.char) C.int {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	signatures := splitPGPSignatures(C.GoString(signature))
	publicKeyObj, err := crypto.NewKeyFromArmored(C.GoString(userPublicKey))
	if err != nil {
		return C.int(0)
	}
	signingKeyRing, err := crypto.NewKeyRing(publicKeyObj)
	if err != nil {
		return C.int(0)
	}
	for _, pgpSignatureString := range signatures {
		pgpSignature, err := crypto.NewPGPSignatureFromArmored(pgpSignatureString)
		if err != nil {
			return C.int(0)
		}
		verifyErr := signingKeyRing.VerifyDetached(plainMessage, pgpSignature, crypto.GetUnixTime())
		if verifyErr == nil {
			return C.int(1)
		}
	}
	return C.int(0)
}

//export verifyCleartextMessageArmored
func verifyCleartextMessageArmored(userPublicKey *C.char, armoredSignature *C.char) (*C.char, C.int) {
	clearText, err := helper.VerifyCleartextMessageArmored(C.GoString(userPublicKey), C.GoString(armoredSignature), crypto.GetUnixTime())
	cStr := C.CString(clearText)
	if err == nil {
		return cStr, C.int(1)
	}
	return cStr, C.int(0)
}

//export decrypt
func decrypt(userPrivateKey *C.char, passphrase *C.char, armor *C.char, outError **C.char) *C.char {
	passphraseBytes := []byte(C.GoString(passphrase))
	decryptedMessage, err := helper.DecryptMessageArmored(C.GoString(userPrivateKey), passphraseBytes, C.GoString(armor))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(DecryptError, err))
		return nil
	}
	return C.CString(decryptedMessage)
}

//export encryptBinary
func encryptBinary(userPrivateKey *C.char, binaryMessage *C.char, length C.int, outError **C.char) C.struct_BinaryResult {
	var result C.struct_BinaryResult
	result.data = nil
	result.length = 0

	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	key, err := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return result
	}
	userPublicKey, err := key.GetArmoredPublicKey()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return result
	}
	armor, err := helper.EncryptBinaryMessageArmored(userPublicKey, data)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(EncryptError, err))
		return result
	}
	encryptedBinary, err := armor_helper.Unarmor(armor)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return result
	}
	resultBytes := GoBytes2CBytes(encryptedBinary)
	resultBytesLength := C.int(len(encryptedBinary))
	return C.struct_BinaryResult{length: resultBytesLength, data: resultBytes}
}

//export encryptBinaryArmor
func encryptBinaryArmor(userPrivateKey *C.char, binaryMessage *C.char, length C.int, outError **C.char) *C.char {
	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	key, err := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	userPublicKey, err := key.GetArmoredPublicKey()
	if err != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, err))
		return nil
	}
	armor, err := helper.EncryptBinaryMessageArmored(userPublicKey, data)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(EncryptError, err))
		return nil
	}
	return C.CString(armor)
}

//export decryptBinary
func decryptBinary(userPrivateKey *C.char, passphrase *C.char, encryptedBinary *C.char, length C.int, outError **C.char) C.struct_BinaryResult {
	data := C.GoBytes(unsafe.Pointer(encryptedBinary), length)
	passphraseBytes := []byte(C.GoString(passphrase))
	ciphertext := crypto.NewPGPMessage(data)
	message, err := decryptMessage(C.GoString(userPrivateKey), passphraseBytes, ciphertext)
	if err != nil {
		*outError = C.CString(fmt.Sprintf(DecryptError, err))
		return C.struct_BinaryResult{length: C.int(0), data: nil}
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

//export changePrivateKeyPassphrase
func changePrivateKeyPassphrase(privateKey *C.char, oldPassphrase *C.char, newPassphrase *C.char, outError **C.char) *C.char {
	// parse old passphrase
	oldPassphraseBytes := []byte(C.GoString(oldPassphrase))
	// parse new passphrase
	newPassphraseBytes := []byte(C.GoString(newPassphrase))
	// parse private key
	privateKeyObj, parseErr := crypto.NewKeyFromArmored(C.GoString(privateKey))
	if parseErr != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, parseErr))
		return nil
	}
	// unlock private key with old passphrase
	unlockedKeyObj, unlockErr := privateKeyObj.Unlock(oldPassphraseBytes)
	if unlockErr != nil {
		*outError = C.CString(fmt.Sprintf(UnlockError, unlockErr))
		return nil
	}
	// lock private key with new passphrase
	newLockedKeyObj, lockErr := unlockedKeyObj.Lock(newPassphraseBytes)
	if lockErr != nil {
		*outError = C.CString(fmt.Sprintf(UnlockError, lockErr))
		return nil
	}
	// export armored private key
	newPrivateKey, armorErr := newLockedKeyObj.Armor()
	if armorErr != nil {
		*outError = C.CString(fmt.Sprintf(ArmorError, armorErr))
		return nil
	}

	return C.CString(newPrivateKey)
}

func GoBytes2CBytes(bytes []byte) *C.char {
	str := string(bytes)
	cStr := C.CString(str)
	return cStr
}

func main() {}

func (keyArray KeyArray) ToKeyRing() (*crypto.KeyRing, error) {
	kr, err := crypto.NewKeyRing(nil) // create empty KeyRing
	if err != nil {
		return nil, err
	}
	for _, key := range keyArray {
		if err := kr.AddKey(key); err != nil {
			return nil, err
		}
	}
	return kr, nil
}

func splitPGPSignatures(multiSig string) []string {
	beginMarker := "-----BEGIN PGP SIGNATURE-----"
	endMarker := "-----END PGP SIGNATURE-----"

	var signatures []string
	parts := strings.Split(multiSig, beginMarker)

	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}

		signature := beginMarker + "\n" + part
		if strings.Contains(signature, endMarker) {
			signatures = append(signatures, signature)
		}
	}

	return signatures
}

//export freeCString
func freeCString(cstr *C.char) {
	C.free(unsafe.Pointer(cstr))
}

//export freeBinaryResult
func freeBinaryResult(result C.struct_BinaryResult) {
	if result.data != nil {
		C.free(unsafe.Pointer(result.data))
	}
}
