<template>
  <Layout :show-logo="false">
    <!-- Author intro -->
    <Author :show-title="true" />

    <!-- List posts -->
    <div class="posts">
      <PostCard
        v-for="edge in $page.posts.edges"
        :key="edge.node.id"
        :post="edge.node"
      />
    </div>

    <!-- Pagination -->
    <Pager :info="$page.posts.pageInfo" linkClass="pager__link" class="pager" />
  </Layout>
</template>

<page-query>
query ($page: Int) {
  posts: allPost(perPage: 5, page: $page) @paginate {
    pageInfo {
      totalPages
      currentPage
    }
    edges {
      node {
        id
        title
        date (format: "D. MMMM YYYY")
        timeToRead
        description
        cover_image (width: 770, height: 380, blur: 10)
        path
        tags {
          id
          title
          path
        }
      }
    }
  }
}
</page-query>

<script>
import { Pager } from "gridsome";
import Author from "~/components/Author.vue";
import PostCard from "~/components/PostCard.vue";

export default {
  components: {
    Pager,
    Author,
    PostCard,
  },
  metaInfo: {
    title: "Cool",
  },
};
</script>

<style lang="scss">
.pager {
  max-width: var(--content-width);
  margin: 0 auto;
  text-align: center;

  &__link {
    color: var(--link-color);
    text-align: center;
    text-decoration: none;
    padding: 0.5rem 1rem;

    &:hover:not(.active) {
      background-color: var(--bg-content-color);
      border-radius: 5px;
      color: var(--link-color);
    }
  }
}

.active {
  background-color: var(--bg-content-color);
  border-radius: 5px;
}
</style>
