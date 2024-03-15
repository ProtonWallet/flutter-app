use andromeda_api::contacts::ApiContactEmails;
#[derive(Debug)]
pub struct ProtonContactEmails {
    pub id: String,
    pub name: String,
    pub email: String,
    pub canonical_email: String,
    pub is_proton: u32,
}

impl From<ApiContactEmails> for ProtonContactEmails {
    fn from(contact_emails: ApiContactEmails) -> Self {
        ProtonContactEmails {
            id: contact_emails.ID,
            name: contact_emails.Name,
            email: contact_emails.Email,
            canonical_email: contact_emails.CanonicalEmail,
            is_proton: contact_emails.IsProton,
        }
    }
}
