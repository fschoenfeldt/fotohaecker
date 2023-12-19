const handleNavigateToPhotoClick = (e, that) => {
  e.preventDefault();
  that.pushEvent("navigate_to", {
    photo_id: that.el.dataset.photoId,
  });
};

const handleEditPhotoFieldClick = (e, that) => {
  e.preventDefault();

  const fieldToEdit = that.el.dataset.field;

  that.pushEvent(
    "activate_edit_mode",
    {
      field: fieldToEdit,
    },
    (_reply, _ref) => {
      const inputToFocus = document.querySelector(
        `input[name="photo[${fieldToEdit}]"]`
      );

      inputToFocus.focus();
      inputToFocus.select();
    }
  );
};

export const Hooks = {
  NavigateToPhoto: {
    mounted() {
      this.el.addEventListener("click", (e) =>
        handleNavigateToPhotoClick(e, this)
      );
    },
  },
  EditPhotoField: {
    mounted() {
      this.el.addEventListener("click", (e) =>
        handleEditPhotoFieldClick(e, this)
      );
    },
  },
};
