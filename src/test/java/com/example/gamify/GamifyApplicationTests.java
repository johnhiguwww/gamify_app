package com.example.gamify;

import com.example.gamify.models.entities.Attributes;
import com.example.gamify.models.entities.Profile;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertSame;

class GamifyApplicationTests {

    @Test
    void newProfileHasDefaultAttributes() {
        Profile profile = new Profile();

        assertNotNull(profile.getAttributes());
        assertSame(profile, profile.getAttributes().getProfile());
    }

    @Test
    void profileReplacesMissingAttributesWithDefaults() {
        Profile profile = new Profile(UUID.randomUUID(), "jane@example.com", "Jane Doe", null, 1, 0, 0, null);

        assertNotNull(profile.getAttributes());
        assertSame(profile, profile.getAttributes().getProfile());
    }

    @Test
    void profileAssociatesProvidedAttributes() {
        Profile profile = new Profile();
        Attributes attributes = new Attributes();

        profile.setAttributes(attributes);

        assertSame(attributes, profile.getAttributes());
        assertSame(profile, attributes.getProfile());
    }
}
