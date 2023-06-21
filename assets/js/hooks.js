const handleNavigateToPhotoClick = (e, that) => {
  e.preventDefault();
  that.pushEvent("navigate_to", {
    photo_id: that.el.dataset.photoId,
  });
};

export const Hooks = {
  NavigateToPhoto: {
    mounted() {
      this.el.addEventListener("click", (e) =>
        handleNavigateToPhotoClick(e, this)
      );
    },
  },
};
