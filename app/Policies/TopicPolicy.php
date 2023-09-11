<?php

namespace App\Policies;

use App\Models\Topic;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class TopicPolicy
{
    use HandlesAuthorization;


    public function follow(User $user, Topic $topic)
    {
        return !($user->followTopic->contains($topic));
    }

    public function unfollow(User $user, Topic $topic)
    {
        return $user->followTopic->contains($topic);
    }
}
