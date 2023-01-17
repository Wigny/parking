const LocalDateTime = {
  mounted() {
    const date = new Date(this.el.textContent);
    const formatter = new Intl.DateTimeFormat([], {
      dateStyle: "short",
      timeStyle: "medium",
    });

    this.el.textContent = formatter.format(date);
  },
};

export default LocalDateTime;
